var app = Elm.Pling.fullscreen();

var context;
var buffers = [];
window.addEventListener('load', init, false);

function init() {
    try {
    // Fix up for prefixing
    window.AudioContext = window.AudioContext||window.webkitAudioContext;
    context = new AudioContext();
    }
    catch(e) {
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

//var startTime = context.currentTime + 0.100;
var tempo = 80; // BPM (beats per minute)
var eighthNoteTime = (60 / tempo) / 2;

app.ports.playNotes.subscribe(function (matrix) {
    for (var i = 0; i < 8; i++) {
        var time = eighthNoteTime + i;
        var notelist = matrix[i];
        
        for (var j = 0; j < 8; j++) {
            var note = notelist[j];
            if (note==true) {
                playSound(buffers[j],time);
            }
            
        }
    }
});


