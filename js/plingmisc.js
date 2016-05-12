
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

    //app.ports.buffers.send(buffers);
}

function loadBuffers() {
    bufferLoader = new BufferLoader(
        context,
        [
            '/res/mp3/C4.mp3',
            '/res/mp3/D4.mp3',
            '/res/mp3/E4.mp3',
            '/res/mp3/F4.mp3',
            '/res/mp3/G4.mp3',
            '/res/mp3/B4.mp3',
            '/res/mp3/A4.mp3',
            '/res/mp3/C5.mp3'
        ],
        finishedLoading
    );

    bufferLoader.load();
}

function finishedLoading(bufferList) {
    buffers = bufferList;
}

function playSound(buffer, time) {
    var source = context.createBufferSource();
    source.buffer = buffer;
    source.connect(context.destination);
    if (!source.start)
        source.start = source.noteOn;
    source.start(time);
}

app.ports.playNotes.subscribe(function (json) {

    obj = JSON && JSON.parse(json);
    console.log("" + json);
    console.log("" + obj);

    for (var i = 0; i < obj.length; i++) {
        tone = buffers[obj[i].tone];
        time = context.currentTime + obj[i].time;
        playSound(tone,time);
    }


});
