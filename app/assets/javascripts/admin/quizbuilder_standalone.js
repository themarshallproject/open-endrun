(function() {

$(document).ready(function(){


  $('.markdown-link-tool').on('mousedown', function(e){
    e.preventDefault();
    $this = $(':focus');
    var url = prompt("URL:");
    console.log(url)
    $this.surroundSelectedText('<a href='+url+'>', '</a>');
    make_dirty($this);
  });
  $('.markdown-bold-tool').on('mousedown', function(e){
    $this = $(':focus');
    e.preventDefault();
    $this.surroundSelectedText("<b>", "</b>");
    make_dirty($this);
  });
  $('.markdown-italic-tool').on('mousedown', function(e){
    $this = $(':focus');
    e.preventDefault();
    $this.surroundSelectedText("<i>", "</i>");
    make_dirty($this);
  });

	$(function() {
	    if ( document.location.href.indexOf('debug') > -1 ) {
	        $('.quiz-debug').show();
	    }
	});

    var quizTemplate;
	var data;

	var generateID = function(prefix) {
		var i;
		var num_chars = 10;
		var chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.split('');
		var chars_length = chars.length;
		var uuid_array = [];
		for (i=0; i<num_chars; i++) {
			uuid_array[i] = chars[0 | Math.random()*chars_length];
		}
		return prefix + "_" + uuid_array.join('');
	}

	var injectID = function (object) {
		if (object['_id']) {
			// already has an ID, do nothing
		} else {
			object['_id'] = generateID('z');
		}
		return object;
	}
	var enumInjectID = function(objects) {
		return objects.map(function(object) {
			return injectID(object);
		});
	}

	var questionForId = function(id) {
		return data.questions.filter(function(question) {
			return question['_id'] === id;
		})[0];
	}

	var answerForId = function(id) {
		var doubleWrappedAnswer = data.questions.map(function(question) {
			return question.answers.filter(function(answer) {
				return answer['_id'] === id;
			});
		}).filter(function(matchingAnswerArray) {
			return matchingAnswerArray.length > 0;
		});
		var singleWrappedAnswer = null;
		var answer = null;

		if (doubleWrappedAnswer) {
			singleWrappedAnswer = doubleWrappedAnswer[0];
		}
		if (singleWrappedAnswer && singleWrappedAnswer.length > 0) {
			answer = singleWrappedAnswer[0];
		}

		return answer;
	}

	// // // // //

	var reorder = function(unsorted) {
		return unsorted.sort(function(a, b){
			return parseInt(a.position, 10) - parseInt(b.position, 10);
		});
	}

	var reorderQuestions = function(unsortedQuestions) {
		return reorder(unsortedQuestions).map(function(question) {
			question.answers = reorder(question.answers);
			return question;
		});
	}

	var newAnswer = function(i) {
		return {
			position: data.questions[i].answers.length + 1,
			text: "",
			correct: false
		}
	}

	var newQuestion = function() {
		return {
			position: data.questions.length + 1,
			text: "",
			img_url: "",
			explanation: "",
			answers: []
		}
	}

	$(function() {
		$("#sortable").sortable({
	        stop: function() {
	            $("#sortable li").each(function(i){
	            	newPosition = i + 1;
	            	id = $(this).attr("data-id");
	            	question = questionForId(id);
					if (question) {
						question.position = newPosition;
					}
					build();
	            });
	        }
	    });
		$("ul, li").disableSelection();
	});


	// var dom_id = null;
	// var synth_id = null;
	// (function() {
	// 	$(document).on('click', 'body', function() {
	// 		var el = document.activeElement;
	// 		dom_id   = el.getAttribute('id');
	// 		synth_id = el.getAttribute('data-id');
	// 		console.log('click', dom_id, synth_id)
	// 	});
	// })();
	// var restoreCursor = function() {
	// 	console.log('restoreCursor', dom_id, synth_id)
	// 	if (synth_id) {
	// 		console.log("restore to data-id", synth_id)
	// 		return;
	// 	}
	// 	if (dom_id) {
	// 		$("#"+dom_id).focus();
	// 		console.log("restored to dom id #"+dom_id);
	// 		return;
	// 	}
	// 	console.log('restoreCursor called but no restore data present');
	// }

	var isDirty = false;
	var markDirty = function() {
		if (isDirty === false) {
			isDirty = true;
			console.log('markDirty')
		}
	};
	var markClean = function() {
		isDirty = false;
		console.log('markClean');
	}

	var buildSorter = function() {
		data.questions = enumInjectID(data.questions).map(function(question) {
			question.answers = enumInjectID(question.answers);
			return question;
		});

		var quizData = {
			slug: data.slug,
			description: data.description,
			creator: data.creator,
			created: data.created_at,
			style: data.reveal_type,
			facebook: data.facebook_share,
			twitter: data.twitter_share,
			questions: reorderQuestions(data.questions)
		}
		$("#sortable").html(quizDraggable(quizData));
	}

	var buildCode = function() {
		var jsonStr = JSON.stringify(data);
		$(".quiz-json").text(jsonStr);
	}

    var build = function() {
    	console.log("build()")
    	buildSorter();

		data.questions = enumInjectID(data.questions).map(function(question) {
			question.answers = enumInjectID(question.answers);
			return question;
		});

		var quizData = {
			slug: data.slug,
			description: data.description,
			creator: data.creator,
			created: data.created_at,
			style: data.reveal_type,
			facebook: data.facebook_share,
			twitter: data.twitter_share,
			questions: reorderQuestions(data.questions)
		}

		$(".quiz-editor").html(quizTemplate(quizData));

		buildCode();


		$(".new_answer").click(function(){
			var findId = $(this).attr("data-id");
			for (var i = 0; i < data.questions.length; i++){
			  if (data.questions[i]._id == findId){
			  	data.questions[i].answers.push(newAnswer(i))
			  }
			}
			build();
		});

		$(".delete").click(function(i){
			var questionId = $(this).attr("data-question");
			var id = $(this).attr("data-id");
			var answer = answerForId(id);
			if (answer) {
				for (var i = 0; i < data.questions.length; i++){
				  	if (data.questions[i]._id == questionId){
						data.questions[i].answers = data.questions[i].answers.filter(function(answer) {
							return answer['_id'] !== id;
						});
						$.each(data.questions[i].answers, function(i, answer){
							answer.position = i + 1;
						});
					}
				}
				build();
				return;
			}
			var question = questionForId(id);
			if (question) {
				data.questions = data.questions.filter(function(question) {
					return question['_id'] !== id;
				});
				$.each(data.questions, function(i, question){
					question.position = i + 1;
				});
				build();
				return;
			}
		});

		$(".new_question").click(function(){
			data.questions.push(newQuestion())
			build();
			buildSorter();
		});

		$(".correct_answer").click(function(){
			var id = $(this).attr("data-id");
			var answer = answerForId(id);

			var current = answer.correct;
			if (current === true || current === false) {
				answer.correct = !current;
			} else {
				answer.correct = false;
			}

			build();
		});

		$(".quiz-checkbox").each(function(){
			var style = $(this).attr("data-value");
			if (data.reveal_type == style){
				$(this).addClass("quiz-checked");
			}
		})

		$(".quiz-checkbox").click(function(){
			data.reveal_type = $(this).attr("data-value");
			build();
		});

		$('body').on('keyup', '.quiz-meta-editable', function() {
			data.slug = $('.quiz-slug').val();
			data.description = $('.quiz-desc').val();
			data.creator = $('.quiz-creator').val();
			data.twitter_share = $('.quiz-tw').val();
			data.facebook_share = $('.quiz-fb').val();
			markDirty();
			buildCode();
		});

		data.created_at = $.now();
	}

	$('body').on('keyup', '.quiz-editable', function() {
		// .quiz-editable is purely for questions and answers

		var $this = $(this);
		var id = $(this).attr('data-id');

		var answer = answerForId(id);
		if (answer) {
			answer.text = $this.val();
			buildSorter();
			buildCode();
			return;
		}

		var question = questionForId(id);
		if (question) {
			question.text        = $('.quiz-question[data-id='    + id + ']').val();
			question.img_url     = $('.quiz-img[data-id='         + id + ']').val();
			question.explanation = $('.quiz-explanation[data-id=' + id + ']').val();
			buildSorter();
			buildCode();
			return;
		}
	});

	$('body').on('click', '.quiz-save-button', function() {
		var $el = $(this);
		var previousText = $el.text();

		var json = JSON.stringify(data);
		var slug = data.slug;
		console.log('POST', slug, json);

		$el.text("Saving...");
		$.post("/admin/v1/quizbuilder/create", {
			slug: slug,
			content: json,
		}).success(function(responseData) {
			console.log('success', responseData);
			$el.text("Saved!");
			data.slug = responseData.slug; // override slug if it's changed on the server side
			build();
			embed();
			//
			// use this to construct embed code
			function embed() {
				$(".quiz-embed").show();
				$(".quiz-json-url").text(responseData.public_url);
			}

			console.log(responseData.public_url)

			history.replaceState({}, "Quiz Updated", "/admin/quizbuilder/edit?asset_file_id="+responseData.asset_file_id)

			hasPreview = $el.attr("data-preview");

			console.log("PREVIEW", hasPreview)

			if (hasPreview === "true") {
				window.open("/admin/quizbuilder/preview/"+responseData.asset_file_id)
			}

			setTimeout(function() {
				$el.text(previousText);
			}, 2000);
		}).fail(function(responseData) {
			console.log('fail', responseData);
			$el.text("Error Saving. Try Again?");
		});
	});

	var loadData = function() {
	 	if (window.existingQuiz === null) {
	 		data = window.exampleQuiz;
			build(data);
			return;
	 	} else {
	 		$(".quiz-embed").show();
	 		$(".quiz-json-url").text(window.existingQuiz.public_url);
	 	}

		$.getJSON(existingQuiz.s3_url, function(existingQuiz) {
			console.log('loaded existing quiz:', existingQuiz);
			data = existingQuiz;
			build();
		});
	}
    function init() {
    	quizTemplate = _.template($("#quiz-editor-template").html());
    	quizDraggable = _.template($("#quiz-draggable-template").html());
        loadData();
    }
    init();

	$(".quiz-accordion-button").click(function(){
		$(this).siblings().toggle();
	});
});
})();