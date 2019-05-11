import processing.video.*;
import themidibus.*;

Capture camera1;
Capture camera2;
Capture cameraRunning;
MidiBus myBus;

float scaleX = 1.75;
float scaleY = 1.4;
float scale = 1;
boolean delayToggle = true;
boolean cameraToggle = false;
int drawType = 0;
int cam1 = 0;
int cam2 = 0;

PImage[] frames;

int index = 0;
int index_draw = 0;
int index_delay = 0;
float frame_delay = 14.0;
int frame_count = 26;
String cam1Check = "";
String cam2Check = "";
void setup()
{
  MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.
  myBus = new MidiBus(this, 0, 0); // Create a new MidiBus with no input device and the default Java Sound Synthesizer as the output device.
  fullScreen(3);
  //size(640, 480, P3D);
  colorMode(HSB, 255);

  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("");
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) 
    {
      println(i + " camera:"+cameras[i]);
      if(cameras[i].equals("name=HD Pro Webcam C920,size=1920x1080,fps=30"))
      {
        cam1 = i;
        println(i + " camera:"+cameras[i]);
      }
      else if(cameras[i].equals("name=HD Pro Webcam C920 #2,size=1920x1080,fps=30"))
      {
        cam2 = i;
        println(i + " camera:"+cameras[i]);
      }
    }
  } 
  
  //initialize frames
  frames = new PImage[frame_count];
  for(int i = 0; i < frame_count; i++)
  {
      frames[i] = createImage(0, 0, 0);
  }
  
  //setup cameras
  camera1 = new Capture(this, int(width/scale), int(height/scale), cameras[cam1]);
  camera1.start();
  cameraRunning = camera1; //setup using first camera
  //println("captureStart: "+camera1);
  camera2 = new Capture(this, int(width/scale), int(height/scale), cameras[cam2]);
  camera2.start();
}

void draw()
{
  background(255);
  
  if(drawType == 0) //camera
  {
    if(index - 1 >= 0)
    {
      index_draw = index - 1;
    }
    else
    {
      index_draw = frame_count-1;
    }  
  
    //allows for scaling of image to match projection
    image(frames[index_draw],int(width*(scaleX-1)/-3),int(height*(scaleY-1)/-3),int(width*scaleX),int(height*scaleY));
  
    //if delay is initialized
    if(delayToggle)
    {     
      blend(frames[index_delay], 0, 0, int(width/scale), int(height/scale), int(width*(scaleX-1)/-3), int(height*(scaleY-1)/-3), int(width*scaleX), int(height*scaleY), OVERLAY);   
    }
    else
    {
      blend(frames[index_draw], 0, 0, int(width/scale), int(height/scale), int(width*(scaleX-1)/-3), int(height*(scaleY-1)/-3), int(width*scaleX), int(height*scaleY), OVERLAY);
    }
  }
  else
  {
     if(drawType == 1) //blank background
     {
       background(0);
     }
     else if (drawType == 2) //white background
     {
       background(255);
     }
  }
}
 
void keyPressed() 
{ 
   if (key == 27) //ESC key
   { 
     exit(); 
   }
   else if(key == 'w')
   {
     drawType = 2;
   }
   else if(key == 'b')
   {
     drawType = 1;
   }
   else if(key == 'c') //
   {
     drawType = 0;
     cameraToggle = !cameraToggle;
     if(cameraToggle)
     {
       cameraRunning = camera2;
     }
     else
     {
       cameraRunning = camera1;
     }
   }
   else if(key == 'd')
   {
     println("delay switched");
     delayToggle = !delayToggle;
   }
}
  
//captures video
void captureEvent(Capture camera)
{ 
  if(cameraRunning == camera) //make sure camera is correct camera
  {
  //println("captureEvent: "+camera);
    camera.read();
    PImage p = camera; 
    //if(delayToggle)
    //{
      frames[index] = p.copy();
    //}
    
      //setup index
    index += 1;  
    if(index >= frame_count)
    {
      index = 0;
    }
    
    //setup delay
    index_delay = index - int(frame_delay);
    if(index_delay < 0)
    {
      index_delay = index_delay + frame_count;
    }
  }
}

//MIDI FUNCTIONS

//BUTTONS
void noteOn(int channel, int pitch, int velocity) {
  if(pitch == 40)
  {
    if(drawType == 1)
    {
      drawType = 0;
    }
    else
    {
      drawType = 1;
    }
  }
  else if (pitch == 41)
  {
    if(drawType == 2)
    {
      drawType = 0;
    }
    else
    {
      drawType = 2;
    }
  }
  else if (pitch == 42)
  {
    drawType = 0;
  }
  else if (pitch == 43)
  {
    delayToggle = !delayToggle;
    if(drawType != 0)
    {
      drawType = 0;
    }
  }
  
}

//KNOBS
void controllerChange(int channel, int number, int value) {
  
  //number: 9 = delay, 15 = xScale, 16 = yScale
  if(number == 15 || number == 16)
  {
    if(number ==15)
    {
      scaleX = 1.00 + (value/127.00)*0.5;
      //println("scaleX:"+scaleX +" ["+value+"]");
    }
    else if(number == 16)
    {
      scaleY = 1.00 + (value/127.00)*0.5;
      //println("scaleY:"+scaleY +" ["+value+"]");
    }
  } 
  else if(number == 9)
  {
    frame_delay = (value/127.0)*frame_count;
    if(frame_delay < 1)
    {
       frame_delay = 1; 
    }
    //println("frame delay:"+frame_delay);
  }
}
