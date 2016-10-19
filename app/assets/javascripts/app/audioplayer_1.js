// <div data-audioplayer data-audioplayer-src="https://tmp-uploads-2.s3.amazonaws.com/201503-horton-temp/Dukakis-3.mp3"></div>
// <div data-audioplayer data-audioplayer-src="https://tmp-uploads-2.s3.amazonaws.com/201503-horton-temp/14_IDon%27tNeedToForgive.mp3"></div>

(function() {
	try {
		var audioContext = new (window.AudioContext || window.webkitAudioContext)();
		window._featureSupport_AudioContext = true;
	} catch(e) {
		var audioContext = null;		
		window._featureSupport_AudioContext = false;
	}

 	//audioContext = null; // for IE testing, uncomment

 	var bootTime = (new Date()).getTime();
 	var sendEvent = function(data) {
 		var img = new Image(1, 1);
 		data.uuid = window.request_uuid();
 		data.url = window.location.href;
 		data.env = window.endrun_config.env;
 		data.time_delta = (new Date()).getTime() - bootTime;
 		data.scroll_position = $(window).scrollTop();
		img.src = "https://d18glvfsbyiquw.cloudfront.net/g.gif?source=audioplayer1&"+jQuery.param(data);
 	}

	var unlockWebkitAudio = function() {
		
			window._unlockedWebkitAudio = false;
			window.addEventListener('touchstart', function() {
				if (window._unlockedWebkitAudio === true) {
					return;
				}
				try {
					var buffer = audioContext.createBuffer(1, 1, 22050);
					var source = audioContext.createBufferSource();
					source.buffer = buffer;
					source.connect(audioContext.destination);
					source.noteOn(0);
					window._unlockedWebkitAudio = true;
				} catch(e) {
					window._unlockedWebkitAudioDebug = "try/catch failed in unlockWebkitAudio";
				}
			}, false);
		
	}

	var generateElementID = function() {
		var i;
		var num_chars = 6;
		var chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.split('');
		var chars_length = chars.length;
		var uuid_array = [];
		for (i=0; i<num_chars; i++) {
			uuid_array[i] = chars[0 | Math.random()*chars_length];
		}	
		return uuid_array.join('');
	}

	var insertAfter = function(newNode, referenceNode) {
		// http://stackoverflow.com/a/4793630
		referenceNode.parentNode.insertBefore(newNode, referenceNode.nextSibling);
	}

	var enabledPlayers = function() {
		return $('[data-audioplayer="v1"]');		
		//return $('.component-audioplayer-v1');
	}

	var isRunning = function($el) {
		return $el.attr('data-audioplayer-running') === 'true';
	}

	var setupPlayers = function() {
		unlockWebkitAudio();
		enabledPlayers().each(function(_, el) {
			buildPlayer(el);
		});
	}

	var timecodeToSeconds = function(timecode) {
		var pieces = timecode.split(":");
		var minutes = parseInt(pieces[0], 10);
		var seconds = parseFloat(pieces[1]);
		return minutes*60.0 + seconds;
	}


	var selectCurrentCaptions = function(seconds, captions) {
		return captions.filter(function(caption) {
			return (caption.start <= seconds && seconds < caption.end) === true;
		});
	}

	var processCSV = function(lines) {
		return lines.split("\n").map(function(line) {
			return line.split(",");
		}).map(function(row) {
			return {
				start: timecodeToSeconds(row[0]),
				end:   timecodeToSeconds(row[1]),
				caption: row.slice(2, row.length).join(",")
			}
		});
	}

	var downloadCSV = function(url, callback) {
		$.get(url).fail(function() {
			callback("Error downloading CSV", null);
		}).done(function(data) {
			var csv = processCSV(data);
			// console.log(JSON.stringify({
			// 	url: url,
			// 	csv: data
			// }))
			callback(null, csv);
		});
	}
 
	var downloadGistCaptions = function(gistKey, callback) {
		var serviceUrl = "https://tmp-gist-proxy.herokuapp.com/"
		var requestUrl = serviceUrl + "?id=" + gistKey;

		downloadCSV(requestUrl, function(err, csv) {
			if (err) {
				callback(err);
				return;
			}
			callback(null, csv);
		});
	}

	var monitorPlayerChanges = function(el, captionEl, captions) {		
		var renderCaption = function(time) {
			var activeCaptions = selectCurrentCaptions(time, captions);
			var captionText = activeCaptions.map(function(caption) {				
				return caption.caption;
			}).join("\n");
			return captionText;
		}
		el.addEventListener('timeupdate', function() {
			var time = parseFloat(el.getAttribute('data-playhead-seconds'));
			captionEl.innerHTML = renderCaption(time);
		});

		captionEl.innerHTML = renderCaption(0);
	}

	var dispatchEvent = function(el, eventName) {
		if (document.createEvent) {
			var evt = new Event(eventName);
			el.dispatchEvent(evt);
		} else {
			var evt = document.createEventObject();
    		el.fireEvent('on'+eventName, evt);
		}
	}
	var addMultipleEventListeners = function(el, eventNames, callback) {
		eventNames.split(' ').forEach(function(eventName) {
			el.addEventListener(eventName, callback);
		});
		return true;
	}

	var buildCard = function(el) {
		var name = el.getAttribute('data-name');
		var imageSrc = el.getAttribute('data-image-src');
		if (name === null && imageSrc === null) {
			return;
		}
		var wrapperEl = document.createElement('div');
		wrapperEl.className = 'card';
		el.appendChild(wrapperEl);

		if (imageSrc) {
			var imageEl = document.createElement('img');
			imageEl.className = 'card-image';
			imageEl.style['background-image'] = "url("+imageSrc+")";
			wrapperEl.appendChild(imageEl);
		}
		
		var nameEl = document.createElement('div');
		nameEl.className = 'card-name';
		nameEl.textContent = name;
		wrapperEl.appendChild(nameEl);
	}

	var buildCaptions = function(el) {
		var captionGistKey = el.getAttribute('data-audioplayer-caption-gist-key');
		if (captionGistKey !== null) {
			var captionEl = document.createElement('div');
			captionEl.className = "caption";
			el.appendChild(captionEl);

			downloadGistCaptions(captionGistKey, function(err, captions) {
				if (err) {
					console.log(err);
					return false;
				}
				monitorPlayerChanges(el, captionEl, captions);
			});
			return;
		} 


		var csvUrl = el.getAttribute('data-caption-csv-url');
		if (csvUrl !== null) {
			var captionEl = document.createElement('div');
			captionEl.className = "caption";
			el.appendChild(captionEl);

			downloadCSV(csvUrl, function(err, captions) {
				if (err) {
					console.log(err);
					return false;
				}
				monitorPlayerChanges(el, captionEl, captions);
			});
		}
	}

	var angleFromDyDx = function(dy, dx) {
		var angle = -0.5 * ((Math.atan(dy/dx) / Math.PI) - 0.5);
		if (dx < 0) { 
			// we lose the left/right halfs with atan, so flip to the "left" half by adding 0.5 if dx<0
			// now we have 0.0->1.0
			// 12 oclock is '0'
			angle += 0.5; 
		}
		return angle;
	}
	var distanceFromDyDx = function(dy, dx) {
		return Math.sqrt(dx*dx + dy*dy);	
	}

	var loadFile = function(url, progressCallback, doneCallback) {
		var startTime = (new Date()).getTime();
		var req = new XMLHttpRequest();
		req.open('GET', url, true);
		req.responseType = 'arraybuffer';
		req.onprogress = function(e) {						
			progressCallback(null, e);			
		}
		req.onload = function() {
			var audioData = req.response;
			audioContext.decodeAudioData(audioData, function(buffer) {					
				//console.log('loadFile', url, 'in', (new Date()).getTime()-startTime+'ms');
				audioDataBuffer = buffer;				
				doneCallback(null, audioDataBuffer);
			}, function(error) {
				console.error('loadFile', error);
				doneCallback(error);
			});			
		}
		req.send();
	}


	var buildPlayer = function(el) {

		// TODO:
		// autoplay on IE? (hopefully)
		// progress (maybe)

		var className = "audioplayer-1";
		if (el.className === className) {
			return;
		}
		el.className = className;

		// make some HTML
		buildCard(el);		

		var audioUrl = el.getAttribute('data-audioplayer-src');
		if (audioContext === null) {
			sendEvent({
				event: 'audio_context_not_supported',
				audio_url: audioUrl
			});
			console.log('fallback to <audio>')
			var audioEl = document.createElement('audio');
			audioEl.setAttribute('src', audioUrl);
			audioEl.setAttribute('controls', true);
			audioEl.setAttribute('style', 'display:block; margin:0 auto; width:300px;');
			el.appendChild(audioEl);
			return true;
		}

		buildCaptions(el);
			
		el.addEventListener("tmp_hotzone_start", function() {
			if (isPlaying === false && hotzoneEnabled === true) {
				dispatchEvent(el, 'tmp_play');
			} else {
				// console.log('entered hotzone, but already playing OR hotzone is disabled because of user interaction')
			}
		});
		el.addEventListener("tmp_hotzone_end", function() {
			dispatchEvent(el, 'tmp_pause');
		});
		
		var isHotzone = false;			
		var audioDataBuffer = null;
		var audioSource = null;
		var isPlaying = false;
		var playStartTimestamp = 0; // (new Date()).getTime()
		var playDuration = 0; // seconds		
		var playheadPercentage = 0; // 0->1
		var playheadSeconds = 0;  // seconds
		var resumePlayheadOffset = 0.0; // where the play/pause happens
		var hotzoneEnabled = true;

		var analyser = audioContext.createAnalyser();
		analyser.connect(audioContext.destination);
		analyser.fftSize = 2048;
		analyser.smoothingTimeConstant = 0.8;
		analyser.minDecibels = -120;
		// analyser.maxDecibels = 0;
		
		var play = function() {
			// audioDataBuffer *must* be populated before you call this
			if (isPlaying) {
				return false;
			}
			
			sendEvent({
				event: 'play',
				audio_url: audioUrl
			});

			audioSource = audioContext.createBufferSource();
			audioSource.buffer = audioDataBuffer;
			audioSource.connect(analyser);
			
			playDuration = audioSource.buffer.duration;			
			resumePlayheadOffset = resumePlayheadOffset % playDuration;
			if (resumePlayheadOffset < 0.5) {
				// console.log('rPO is <1, setting to 0')
				resumePlayheadOffset = 0; // if we're in the first second of the file, start from the very beginning
			}
			audioSource[audioSource.start ? 'start' : 'noteOn'](0, resumePlayheadOffset);
			playStartTimestamp = (new Date()).getTime();
			isPlaying = true; // this must be before drawAudioFFT and dispatchEvent

			// console.log('play at', resumePlayheadOffset);

			dispatchEvent(playheadSVG, 'update_controls');
			drawAudioFFT();
			var currentTimeInterval = setInterval(function() {
				var secondsSinceResume = ((new Date()).getTime() - playStartTimestamp) / 1000.0;
				playheadSeconds = resumePlayheadOffset + secondsSinceResume;
				playheadPercentage = playheadSeconds / playDuration;

				if (playheadPercentage >= 1) {
					// we're done, reset stuff, prep to cancel this timer ticking
					playheadSeconds = 0;
					resumePlayheadOffset = 0;
					isPlaying = false;
					dispatchEvent(el, 'timeupdate');
				}
				el.setAttribute('data-playhead-seconds', playheadSeconds);

				if (isPlaying === false) {
					clearInterval(currentTimeInterval);					
					dispatchEvent(playheadSVG, 'update_controls');
				} else {
					// we are playing, so keep dispatching stuff every 0.1 seconds
					dispatchEvent(el, 'timeupdate');
				}

			}, 100);
		}
		el.addEventListener('tmp_play', function() {
			isHotzone = true;
			if (!audioDataBuffer) {
				loadFile(audioUrl, function(err, progressEvent) {
					// progress event
					var percentage = 1.0 * progressEvent.loaded / progressEvent.total;
					el.setAttribute('data-load-ratio', percentage);
					dispatchEvent(el, 'sync_load_ratio');

				}, function(err, buffer) {
					// loading is done
					if (err) { 
						console.error(err); 
					}	
					audioDataBuffer = buffer; // scoped for the individual player					
					if (isHotzone === true) {
						play();						
					} else {
						// console.log('finished loading, but now were out of the hotzone for', el)
					}
				});
			} else {
				// console.log('already have an audiosource, playing')
				play();
			}					
		});
		el.addEventListener('tmp_pause', function() {			
			// console.log('tmp_pause', el);
			isHotzone = false;

			if (audioSource === null) {		
				// console.log('pause by audioSource is already null')		
				return false;
			}
			
			audioSource[audioSource.stop ? 'stop': 'noteOff'](0);
			audioSource.disconnect(analyser);
			audioSource = null;
			isPlaying = false;
			resumePlayheadOffset = playheadSeconds;
			dispatchEvent(el, 'timeupdate'); // to reset to 0 for data-ratio, prevents tiny slice of playheadSVG
			playheadSeconds = 0;
			dispatchEvent(playheadSVG, 'update_controls');

			sendEvent({
				event: 'pause',
				audio_url: audioUrl
			});
		});


		//////////////////////
		/// FFT VIS START
		var pixelRatio = 1;
		try {
			pixelRatio = parseFloat(window.devicePixelRatio);
		} catch(e) {}
		var width = el.offsetWidth * pixelRatio; // todo should this update/responsive-ness?
		var height = 55 * pixelRatio; // todo un-hardcode?
		var canvas = document.createElement('canvas');
		canvas.width  = ""+width;
		canvas.height = ""+height;
		canvas.style.width = width/pixelRatio + 'px'; // scale for retina
		el.appendChild(canvas);
		var canvasCtx = canvas.getContext("2d");

		var magnitudeForFrequency = function(x, width, freqByteData, activeBinCount) {
			// this is the "requested" frequency
			// but it's a fractional one, as it's coming from the desired x-val on the plot
			var freq_req = (.35*x/width) * activeBinCount; 

			// find the bins on each side of the requested frequency
			var freq_l = Math.floor(freq_req);
			var freq_r =  Math.ceil(freq_req);
			
			// find the magnitudes for those frequencies
			var mag_l = freqByteData[freq_l] / 255; // dividing by 255 scales it to (0->1) because Uint8 is an 8-bit unsigned int (0->255)
			var mag_r = freqByteData[freq_r] / 255;

			// interpolate between _l and _r to find the 'smoothed' y-val for given target freq
			var offset    = freq_req - freq_l;
			var magnitude = (1-offset)*mag_l + offset*mag_r;
			return magnitude;
		}

		var previewFFTData = [164,177,186,191,189,170,184,194,181,177,188,181,163,166,170,169,171,174,167,160,146,142,143,145,142,140,142,138,137,140,130,112,118,118,100,107,112,108,105,94,91,87,90,96,96,93,90,84,88,95,96,93,89,88,92,92,87,87,91,98,97,94,98,99,97,104,110,107,105,105,97,96,99,96,91,98,102,94,78,86,85,78,87,90,92,93,87,85,85,83,92,102,99,88,103,102,88,97,107,107,107,115,117,114,108,98,90,96,100,101,97,86,72,74,70,62,64,71,69,68,72,72,64,54,64,65,64,72,76,70,69,70,61,57,73,82,76,74,83,80,69,72,71,61,63,72,72,65,62,65,62,62,62,63,62,60,53,54,51,50,54,54,57,58,54,52,51,47,51,51,47,53,59,54,48,48,48,45,46,52,49,46,51,49,44,40,40,42,41,37,42,48,45,45,42,43,46,52,53,48,61,62,53,52,50,49,56,61,61,55,48,49,58,61,61,64,70,71,75,72,67,77,76,71,72,71,64,57,51,55,59,51,49,47,45,46,42,39,43,42,36,35,35,35,36,38,39,35,40,41,43,43,41,42,43,48,48,53,56,52,37,53,59,58,55,54,60,64,58,57,50,46,57,52,41,50,62,56,53,61,58,51,59,70,67,54,61,58,56,52,61,64,64,69,75,72,74,81,82,69,67,79,78,72,71,67,69,80,85,84,81,80,77,79,91,95,93,87,80,92,89,82,82,85,79,72,80,85,83,75,79,80,73,64,70,66,68,66,61,70,76,78,75,74,72,77,67,71,74,83,81,76,83,83,78,72,74,65,55,58,68,66,50,53,58,50,54,62,62,56,58,60,59,52,59,63,61,59,60,57,51,44,45,42,34,36,35,34,34,36,38,41,32,38,42,44,42,43,41,45,53,53,46,60,68,62,52,62,60,52,65,69,62,61,68,67,59,54,51,60,59,44,50,57,61,60,54,52,62,61,55,54,57,60,57,53,54,57,61,57,56,52,51,57,56,51,51,59,60,57,54,56,54,47,51,52,47,49,54,50,44,39,36,46,55,54,43,41,45,47,47,47,47,48,45,43,43,42,47,43,32,48,50,35,46,50,47,52,55,48,49,57,59,57,59,59,58,55,64,65,52,55,64,60,53,52,52,51,51,50,54,50,54,54,50,53,57,54,52,52,57,56,46,42,46,53,58,58,57,53,50,56,56,56,51,44,45,51,55,52,47,50,49,49,53,46,38,41,39,41,39,36,33,33,38,36,33,23,37,36,34,30,26,34,40,38,40,41,34,34,32,29,29,31,31,27,29,36,36,32,32,35,36,27,36,40,32,27,29,29,27,31,41,40,47,53,50,49,56,53,53,57,61,61,64,60,56,63,62,55,52,54,54,56,62,59,53,55,54,49,46,40,40,34,35,37,37,32,32,37,34,29,35,37,33,26,26,31,37,39,38,39,39,31,38,40,43,43,41,41,34,37,39,37,42,46,37,41,38,42,44,34,40,43,36,41,39,41,48,45,44,50,46,48,45,33,40,39,34,28,39,44,35,35,44,43,32,35,41,43,40,45,50,47,45,47,46,40,41,47,47,40,40,48,44,35,31,35,32,33,37,44,45,47,51,49,46,49,45,35,36,34,36,39,43,43,32,37,35,37,34,26,29,32,28,29,33,31,23,28,38,39,35,24,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
		var drawEmptyFFT = function() {
			// canvasCtx.fillStyle = 'rgb(246, 246, 245)'; // todo: un-hardcode?
			// canvasCtx.fillRect(0, 0, width, height);
			canvasCtx.clearRect(0, 0, width, height);

			var grd = canvasCtx.createLinearGradient(0, 0,0,height);
			grd.addColorStop(.1,'rgb(126, 126, 125)')
			grd.addColorStop(.4,'rgb(142, 142, 140)')
			grd.addColorStop(.8,'rgb(118, 117, 117)')
			grd.addColorStop(1,'rgb(57, 57, 57)')
			canvasCtx.fillStyle = grd;

			var previewFFTDataLength = previewFFTData.length;
			for(var x=0; x<width; x++) {
				var magnitude = magnitudeForFrequency(x, width, previewFFTData, previewFFTDataLength);
				canvasCtx.fillRect(
					x, 	            // x position, from left
					height/2 - ((height/2)*magnitude), // y position, measured from **top**
					1,              // width
					magnitude*height               // height
				);			
			}
		}
		drawEmptyFFT();

		var drawAudioFFT = function() {			
			// canvasCtx.fillStyle = 'rgb(246, 246, 244)'; // todo: un-hardcode?
			// canvasCtx.fillRect(0, 0, width, height);	
			canvasCtx.clearRect(0, 0, width, height);
			
			// canvasCtx.fillStyle='rgba(255, 11, 58, 1)';
			// grd = canvasCtx.createLinearGradient(0, 0, 0, height);		

			if (analyser !== null) {
				var freqByteData = new Uint8Array(analyser.frequencyBinCount);
	  			analyser.getByteFrequencyData(freqByteData);	  				  		

	  			var activeBinCount = Math.ceil(1*analyser.frequencyBinCount); // only use the 20% on the lowest end.

	  			if (true) {
	  				 var output = [];
	  				 for(var i=0; i<activeBinCount; i++) {
	  				 	output.push(freqByteData[i]);
	  				 }
	  				 // get demo fft
	  				 // console.log(JSON.stringify(output))
	  			}
				for(var x=0; x<width; x++) {
					var magnitude = magnitudeForFrequency(x, width, freqByteData, activeBinCount);
					
					// Create gradient
					if(isNaN(magnitude)) magnitude=1; // not sure why it can be NaN, but it can
					// var grd = canvasCtx.createLinearGradient(0, height/2 - ((height/2)*magnitude),0,(height/2 - ((height/2)*magnitude))+((magnitude*height)+1));

					// just a line waveform
					// grd.addColorStop(0,'rgba(255, 46, 67,1)')
					// grd.addColorStop(.1,'rgba(255, 46, 67,1)')


					
					// centered waveform grdient
					var grd = canvasCtx.createLinearGradient(0, 0,0,height);
					// centered waveform gradients
					grd.addColorStop(0.1, 'rgb(255, 11, 58)');
					grd.addColorStop(0.4, 'rgb(255, 46, 67)');
					grd.addColorStop(0.8, 'rgb(165, 35, 43)');
					grd.addColorStop(1.0, 'rgb(118, 35, 35)');
					// centered waveform
					canvasCtx.fillStyle = grd;
					canvasCtx.fillRect(
						x, 	                               // x position, from left
						height/2-(magnitude*height/2)-1,		//height/2 - ((height/2)*magnitude), // y position, measured from **top**
						1,                                 // width
						magnitude*height+1             // height
					);		
					


					/*
					// flat bottom waveform
					// var grd = canvasCtx.createLinearGradient(0, height-(magnitude*height)-1, 0, height);
					var grd = canvasCtx.createLinearGradient(0, 0,0,height);
					// flat bottom waveform stops
					grd.addColorStop(0,'rgb(255, 114, 108)')
					grd.addColorStop(.65,'rgb(248, 16, 57)')
					// grd.addColorStop(.7,'rgb(255, 46, 67)')
					// grd.addColorStop(.8,'rgb(134, 35, 38)')
					grd.addColorStop(1,'rgb(165, 35, 43)')
					// flat bottom waveform
					canvasCtx.fillStyle = grd;
					canvasCtx.fillRect(
						x,
						height-(magnitude*height)-1,
						1,
						magnitude*height+1
					);		
					*/



				}
				if (isPlaying) {
					requestAnimationFrame(drawAudioFFT);
				} 

  			} else {
  				console.error('no analyzer, drawAudioFFT requested')
  			}

		}
		/// FFT VIS END

		// START playhead controls
		var playheadSVG = TMP_SVG__arc_buildPlayer(70, 6); // width in px, arcWidth in px
		playheadSVG.setAttribute('class', "playhead-svg");
		el.appendChild(playheadSVG);

		el.addEventListener('timeupdate', function() {
			playheadSVG.setAttribute('data-play-ratio', playheadPercentage);
			dispatchEvent(playheadSVG, 'update');
		});
		playheadSVG.setAttribute('data-load-ratio', 0);

		el.addEventListener('sync_load_ratio', function() {
			window.requestAnimationFrame(function() {
				var ratio = el.getAttribute('data-load-ratio');
				playheadSVG.setAttribute('data-load-ratio', ratio);
				dispatchEvent(playheadSVG, 'update');
			});
		});

		addMultipleEventListeners(playheadSVG, 'click touchstart', function(e) {	
			e.preventDefault();	
			var boundingRect = playheadSVG.getBoundingClientRect();
			var width = boundingRect.width;
			var x = e.clientX - boundingRect.left;
			var y = e.clientY - boundingRect.top;
			var dx = Math.min(0.1, x-(width/2.0)); // divide by zero protection, :(
			var dy = (width/2.0) - y;
			var distance = distanceFromDyDx(dy, dx);
			var angle = angleFromDyDx(dy, dx) 
			
			if (distance > width/4) {				
				// TK TK TK TODO TODO
				// this is really complicated with webaudio api?				
			} else {
				// we're 'inside' the click range, so this is a play/pause evnt
				dispatchEvent(el, 'user_toggleplaypause')
			}
		});
		playheadSVG.addEventListener('update_controls', function() {
			// console.log('update_controls', isPlaying)		
			if (isPlaying == false) {
				playheadSVG.querySelector('.play-button').style.opacity  = 1;
				playheadSVG.querySelector('.pause-button').style.opacity = 0;
				
			} else {
				playheadSVG.querySelector('.play-button').style.opacity  = 0;
				playheadSVG.querySelector('.pause-button').style.opacity = 1;
				
			}		
		});
		dispatchEvent(playheadSVG, 'update_controls');
		// END playhead controls
 
		// START playpause
		el.addEventListener('user_toggleplaypause', function() {
			hotzoneEnabled = false;

			if (isPlaying == false) {
				dispatchEvent(el, 'tmp_play');
				sendEvent({
					event: 'click:play',
					audio_url: audioUrl
				});
			} else {
				dispatchEvent(el, 'tmp_pause');
				sendEvent({
					event: 'click:pause',
					audio_url: audioUrl
				});
			}	
		})
		// END playpause

		var countdownEl = document.createElement('div');
		countdownEl.className = "countdown";
		el.appendChild(countdownEl);
		addMultipleEventListeners(el, 'timeupdate', function() {
			var timeRemaining = Math.round(playDuration - playheadSeconds);
			var minutes = Math.floor(timeRemaining / 60);
			var seconds = timeRemaining % 60;
			if (seconds < 10) {
				seconds = "0"+seconds;
			}
			countdownEl.textContent = minutes+":"+seconds;
		});
		countdownEl.textContent = "0:00";
		
	} // end buildPlayer

	$(document).ready(function() {
		setupPlayers();
		
		$(window).on('tmp_stream_open', function() {
			setupPlayers();
		});
	});

})();