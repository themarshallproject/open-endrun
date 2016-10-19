window.TMP_SVG__arc_generateCommand = function(size, arcWidth, destRatio) {

	var width  = size;
	var height = size; 
	var centerX = width/2;
	var centerY = height/2;
	var radius = width/2;
	
    var polarToCartesian = function(centerX, centerY, radius, angleRatio) {
    	// angleRatio is 0->1, where 0 is 12 oclock
        var angleInRadians = ((angleRatio*2)-0.5) * Math.PI;
        var x = centerX + radius * Math.cos(angleInRadians);
        var y = centerY + radius * Math.sin(angleInRadians);
        return [x, y];
    }
    var arc = function(radius, rotation, large_arc_flag, sweep_flag, x, y) {
        return ["A", radius, radius, rotation, large_arc_flag, sweep_flag, x, y].join(" ");
    }

    var destRatio = (destRatio - 0.00001) % 1;

    var outsidePt = polarToCartesian(centerX, centerX, radius,          destRatio);
    var insidePt  = polarToCartesian(centerX, centerX, radius-arcWidth, destRatio);
        
    var commands = [];
    commands.push("M"+centerX+",0");

    commands.push(arc(
        radius, 
        0,                          // rotation, 0 == clockwise
        (destRatio >= 0.5 ? 1 : 0), // large arc flag
        1,                          // sweep flag
        outsidePt[0], outsidePt[1])
    );

    commands.push("L " + insidePt.join(" "));

    commands.push(arc(
        radius-arcWidth, 
        0, 
        (destRatio >= 0.5 ? 1 : 0), // large arc flag 
        0, 
        centerX, arcWidth
    ));

    commands.push("Z");    

    return commands.join("\n");

};

window.TMP_SVG__arc_buildPlayer = function(size, arcWidth) {

    var createSVGElement = function(name) {
        return document.createElementNS("http://www.w3.org/2000/svg", name);
    }
    var rect = function(x, y, width, height) {
        var r = createSVGElement("rect");
        r.setAttribute('x', x);
        r.setAttribute('y', y);
        r.setAttribute('width',  width);
        r.setAttribute('height', height);
        return r;
    }
    // var setAttr = function(el, key, val) {
    //     el.setAttribute(key, val);
    //     return el;
    // }

	var svg  = createSVGElement('svg');
	svg.setAttribute('width',  size+'px');
	svg.setAttribute('height', size+'px');
    svg.setAttribute('shape-rendering', 'geometricPrecision');
	svg.setAttribute('data-play-ratio', '0');
    svg.setAttribute('data-load-ratio', '0');

    var loadhead = createSVGElement("path");
    loadhead.setAttribute('class', 'load');
    svg.appendChild(loadhead);

	var playhead = createSVGElement("path");  
    playhead.setAttribute('class', 'play');
    svg.appendChild(playhead);

    var circle = createSVGElement("circle");  
    svg.appendChild(circle);
    circle.setAttribute('cx', size/2);
    circle.setAttribute('cy', size/2);
    circle.setAttribute('r', (size/2)-arcWidth); // -1 to leave space for a 1px stroke
    circle.setAttribute('class', 'circle');

    var playButton = createSVGElement("g");  
    playButton.setAttribute('class', 'play-button');
    var p = createSVGElement("polygon");  
    p.setAttribute('points', "28,47 28,23 47,35"); // TODO: these should be proportional!
    playButton.appendChild(p);
    svg.appendChild(playButton);

    var pauseButton = createSVGElement("g");  
    pauseButton.setAttribute('class', 'pause-button');  
    pauseButton.appendChild(rect(27, 25, 5, 20));
    pauseButton.appendChild(rect(38, 25, 5, 20));
    svg.appendChild(pauseButton);

	var draw = function() {
		var playRatio = parseFloat(svg.getAttribute('data-play-ratio')) || 0.0;
        var loadRatio = parseFloat(svg.getAttribute('data-load-ratio')) || 0.0;
        if (playRatio >= 1.0) {
            playRatio = 0;
        }
		// todo: check if the command string is different before reflowing
        loadhead.setAttribute('d', TMP_SVG__arc_generateCommand(size, arcWidth, loadRatio));
        playhead.setAttribute('d', TMP_SVG__arc_generateCommand(size, arcWidth, playRatio));
	}

	svg.addEventListener('update', draw);
	draw();
	return svg;
};