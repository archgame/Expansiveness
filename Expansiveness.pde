import processing.video.*;
import themidibus.*;

String _cam1Name = "name=HD Pro Webcam C920,size=1920x1080,fps=30";
String _cam2Name = "name=HD Pro Webcam C920 #2,size=1920x1080,fps=30";
int screen = 1; //change this to make the script run on a different projector

Capture _camera1;
Capture _camera2;
Capture _cameraRunning;
MidiBus _myBus;

float _scaleX = 1.75;
float _scaleY = 1.4;
float _scale = 1;
boolean _delayToggle = true;
boolean _cameraToggle = false;
int _drawType = 0; //0 = camera, 1 = black background, 2 = white background
int _cam1 = 0;
int _cam2 = 0;

PImage[] _frames;

int _index = 0;
int _index_draw = 0;
int _index_delay = 0;
float _frame_delay = 14.0;
int _frame_count = 26;
String _cam1Check = "";
String _cam2Check = "";

PGraphics resized;
float _pixelation = 0;

void setup()
{
  MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.
  _myBus = new MidiBus(this, 0, 0); // Create a new MidiBus with no input device and the default Java Sound Synthesizer as the output device.

  //fullScreen(screen);
  size(640, 480); //P3D, messes up anti-aliasing

  noSmooth(); //remove aliasing

  colorMode(HSB, 255);
  
  String[] cameras = Capture.list();
  
  //guard statement for no camera input
  if (cameras.length == 0) {println("There are no cameras available for capture.");exit();} 
  
  println("");
  println("Available cameras:");
  for (int i = 0; i < cameras.length; i++) 
  {
    //list out all the cameras so we can see what is available
    println(i + " camera:"+cameras[i]);
    //Set camera 1 by name
    if(cameras[i].equals(_cam1Name)){println("SET"); _cam1 = i;}
    //set camera 2 by name
    else if(cameras[i].equals(_cam2Name)){println("SET"); _cam2 = i;}
    
  } 
  
  //initialize frames
  _frames = new PImage[_frame_count];
  for(int i = 0; i < _frame_count; i++)
  {
      _frames[i] = createImage(0, 0, 0);
  }
  
  //setup cameras
  _camera1 = new Capture(this, int(width/_scale), int(height/_scale), cameras[_cam1]);
  _camera1.start();
  _cameraRunning = _camera1; //setup using first camera
  //println("captureStart: "+camera1);
  _camera2 = new Capture(this, int(width/_scale), int(height/_scale), cameras[_cam2]);
  _camera2.start();
}

void draw()
{
  background(255);
  
  if(_drawType == 0) //camera
  {
    if(_index - 1 >= 0)
    {
      _index_draw = _index - 1;
    }
    else
    {
      _index_draw = _frame_count-1;
    }  
  
    //allows for scaling of image to match projection
    image(_frames[_index_draw],int(width*(_scaleX-1)/-3),int(height*(_scaleY-1)/-3),int(width*_scaleX),int(height*_scaleY));
  
    //if delay is initialized
    if(_delayToggle)
    {     
      blend(_frames[_index_delay], 0, 0, int(width/_scale), int(height/_scale), int(width*(_scaleX-1)/-3), int(height*(_scaleY-1)/-3), int(width*_scaleX), int(height*_scaleY), OVERLAY);   
    }
    else
    {
      blend(_frames[_index_draw], 0, 0, int(width/_scale), int(height/_scale), int(width*(_scaleX-1)/-3), int(height*(_scaleY-1)/-3), int(width*_scaleX), int(height*_scaleY), OVERLAY);
    }
    
    if(_pixelation > 0)
    {             
        int cols = int((width/_scale) / _pixelation);
        int rows = int((width/_scale) / _pixelation);
        //draw video resized smaller into a buffer
        resized = createGraphics(cols, rows);
        resized.beginDraw();
        resized.image(get(),0,0,cols,rows);
        resized.endDraw();
        image(resized,0,0,int(width/_scale),int(height/_scale));
    }
  }
  else
  {
     //black background
     if(_drawType == 1) {background(0);}
     //white background
     else if (_drawType == 2) {background(255);}
  }
}
  
//captures video
void captureEvent(Capture camera)
{ 
  if(_cameraRunning == camera) //make sure camera is correct camera
  {
    camera.read();
    PImage p = camera; 

    _frames[_index] = p.copy();
    
    //setup index
    _index += 1;  
    
    //make sure index loops the frame count
    if(_index >= _frame_count){_index = 0;}
    
    //setup delay
    _index_delay = _index - int(_frame_delay);
    if(_index_delay < 0)
    {
      _index_delay = _index_delay + _frame_count;
    }
  }
}

//KEYBOARD

//KEYS
void keyPressed() 
{ 
   //ESC key, exit program
   if (key == 27) { exit(); }
   //White background
   else if(key == 'w'){_drawType = 2;}
   //black background
   else if(key == 'b'){_drawType = 1;}
   //toggle delay
   else if(key == 'd'){_delayToggle = !_delayToggle;}
   //switch input camera
   else if(key == 'c')
   {
     _drawType = 0;
     _cameraToggle = !_cameraToggle;
     if(_cameraToggle){_cameraRunning = _camera2;}
     else{_cameraRunning = _camera1;}
   }
  
  //Coded keys
  if(key == CODED)
  {
    //delay frame
     if(keyCode == UP)
     {
       _frame_delay++;
       //maximum frame value is _frame_count
       if(_frame_delay > _frame_count){_frame_delay = _frame_count;}
     }
     else if(keyCode == DOWN)
     {
       _frame_delay--;
       //keep frame delay to at least 1;
      if(_frame_delay < 1){_frame_delay = 1; }
     }
     
     if(keyCode == RIGHT)
     {
       _pixelation++;
       //maximum frame value is _frame_count
       if(_pixelation > 64){_pixelation = 64;}
     }
     else if(keyCode == LEFT)
     {
       _pixelation--;
       //keep frame delay to at least 1;
      if(_pixelation < 0){_pixelation = 0; }
     }
  }
}

//MIDI FUNCTIONS

//BUTTONS
void noteOn(int channel, int pitch, int velocity) {
  
  println(pitch);
  
  //black draw type
  if(pitch == 40)
  {
    if(_drawType == 1){_drawType = 0;}
    else{_drawType = 1;}
  }
  //white draw type
  else if (pitch == 41)
  {
    if(_drawType == 2){_drawType = 0;}
    else{_drawType = 2;}
  }
  //camera
  else if (pitch == 42){_drawType = 0;}
  //turn delay on and off, if not on camera, go to camera
  else if (pitch == 43)
  {
    _delayToggle = !_delayToggle;
    if(_drawType != 0){_drawType = 0;} //if not on camera, go to camera
  }
  
}

//KNOBS
void controllerChange(int channel, int number, int value) {
  
  println(number);
  
  //number: 9 = delay, 15 = xScale, 16 = yScale
  if(number == 15 || number == 16)
  {
    //scale the screen in the X direction
    if(number ==15){_scaleX = 1.00 + (value/127.00)*0.5;}
    
    //scale the screen in the Y direction
    else if(number == 16){_scaleY = 1.00 + (value/127.00)*0.5;}
  } 
  else if(number == 9)
  {
    //midi values go up to 127
    _frame_delay = (value/127.0)*_frame_count;
    
    //keep frame delay to at least 1;
    if(_frame_delay < 1){_frame_delay = 1; }
  }
  
  else if(number == 10)
  {
    //midi values go up to 127
    _pixelation = value/2.0;
    
    //keep frame delay to at least 1;
    if(_pixelation < 0){_pixelation = 0; }
  }
}
