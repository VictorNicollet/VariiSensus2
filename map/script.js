$('svg').remove();

// Deterministic pseudo-random sequence. 

function Random(seed) 
{
	this.seed = seed;
}

Random.prototype.next  = function() { return new Random(this.seed + 1); }
Random.prototype.value = function(f) {
	var h = this.seed;
	for (var i = 0; i < 10; ++i) 
		h = (h << 5) + (h >> 7) + h + 1; 
	return f ? f(h) : h;
};

function die(sides) { return function(value) { return Math.abs(value % sides); } }
function unit(value) { return Math.abs(value % 65536) / 65536.0; }

// Tesselation functions

function tesselateCircle(x,y,radius,rand) {
	
	var nPoints = 5 + rand.value(die(10));
	rand = rand.next();
	
	var points = [];
	for (var i = 0; i < nPoints; ++i) {
		var a = 6.28304 * i / nPoints;
		
		var r = radius * (0.8 + 0.4*rand.value(unit));
		rand = rand.next();
		
		points.push({
			x: x + Math.cos(a) * r,
			y: y + Math.sin(a) * r
		});
	}
	
	return points;
}

function subTesselate(face,array,rand) {

	var out = [];
	function recurse(depth, prev, next) {
		
		var d = rand.value(die(face));
		rand = rand.next();
		
		if (depth > d) return;
		
		var t = 0.2 + 0.6 * rand.value(unit);
		rand = rand.next();
		
		var off = (rand.value(unit) - 0.5) * 1/(1+depth);
		rand = rand.next();
		
		var M = { 
			x: prev.x * t + next.x * (1 - t) + off * (next.y - prev.y),
			y: prev.y * t + next.y * (1 - t) - off * (next.x - prev.x)
		};
		
		recurse(depth + 1, prev, M);
		out.push(M);
		recurse(depth + 1, M, next);
	}
	
	for (var i = 0; i < array.length; ++i) {
		out.push(array[i]);
		recurse(0, array[i], array[(i + 1) % array.length]); 
	}
	
	return out;
}

// Drawing things

function magnitude(v) { return Math.sqrt(v.x * v.x + v.y * v.y); }

function drawClosedBezier(points) 
{
	var d = [], N = points.length;
	
	d.push("M", 
		points[0].x.toFixed(2), ",", points[0].y.toFixed(2));
	
	for (var i = 0; i < N; ++i) {
	
		// Draws the BC segment by finding the control point M
		
		var A = points[i > 0 ? i - 1 : N - 1];
		var B = points[i];
		var C = points[i + 1 < N ? i + 1 : 0];
		var D = points[i + 2 < N ? i + 2 : i + 2 - N];
		
		var AC = { x: C.x - A.x, y: C.y - A.y };
		var BD = { x: D.x - B.x, y: D.y - B.y };
		var BC = { x: C.x - B.x, y: C.y - B.y };
		
		var BCl = magnitude(BC) * 0.1;
		
		var ACr = BCl / magnitude(AC);
		var MB  = {
			x: B.x + AC.x * ACr,
			y: B.y + AC.y * ACr
		};
		
		var BDr = BCl / magnitude(BD);
		var MC  = {
			x: C.x - BD.x * BDr,
			y: C.y - BD.y * BDr
		};
		
		d.push(" C", 
			MB.x.toFixed(2), ",", MB.y.toFixed(2), " ",
			MC.x.toFixed(2), ",", MC.y.toFixed(2), " ",
			C.x.toFixed(2), ",", C.y.toFixed(2));
	}
	
	d.push(" Z");
		
	return '<path d="' + d.join('') + '" stroke="#111111" fill="none" stroke-width="2"/>';
}

var svg = [
	'<svg width="1200px" height="700px" viewBox="0 0 1200 700" xmlns="http://www.w3.org/2000/svg" version="1.1">',
	drawClosedBezier(subTesselate(2, tesselateCircle(600,350,300,new Random(1)), new Random(1))),
	'</svg>'
].join('');

$('body').html(svg);