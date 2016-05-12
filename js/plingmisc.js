
var app = Elm.Pling.fullscreen();

var context = null;
var buffers = [];
window.addEventListener('load', init, false);

function init() {
    try {
        // Fix up for prefixing
        window.AudioContext = window.AudioContext || window.webkitAudioContext;
        context = new AudioContext();
    }
    catch (e) {
        alert('Web Audio API is not supported in this browser');
    }

    loadBuffers();
}

function loadBuffers() {
    bufferLoader = new BufferLoader(
        context,
        [
            'res/guitar/d5.mp3',
            'res/guitar/a4.mp3',
            'res/guitar/e4.mp3',
            'res/guitar/b3.mp3',
            'res/guitar/g3.mp3',
            'res/guitar/d3.mp3',
            'res/guitar/a2.mp3',
            'res/guitar/e2.mp3'
        ],
        function (bufferList) {
            buffers = bufferList;
        }
    );

    bufferLoader.load();
}

function playSound(buffer, time) {
    var source = context.createBufferSource();
    source.buffer = buffer;
    source.connect(context.destination);
    source.start(time);
}

app.ports.playNotes.subscribe(function (json) {

    var obj = JSON && JSON.parse(json);
    //console.log("" + json);
    var curTime = context.currentTime;
    
    for (var i = 0; i < obj.length; i++) {
        var tone = buffers[obj[i].tone];
        var time = curTime + obj[i].time;
        playSound(tone,time);
    }
});
