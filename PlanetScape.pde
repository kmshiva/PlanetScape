import java.util.*;
import controlP5.*;

ControlP5 controlP5;

PFont font;

BackgroundStars bgStars;

Button btnStar;
Button btnPlanet;

Timeline timeline;
GravitySimulation sim;
Star sun;
Planet planet;
Planet planet2;

controlP5.Button btnRewind;
controlP5.Button btnPlayPause;
controlP5.Button btnFastForward;
controlP5.Slider sliderTimeline;

boolean paused;
boolean dragging;
boolean rightClick;

boolean drawVectors;

void setup()
{
  size(1024, 768);
  background(0);
  frameRate(30);
  smooth();
  
  drawVectors = false;
  
  paused = true;
  
  font = loadFont("Verdana-10.vlw"); 
  textFont(font);
  
  bgStars = new BackgroundStars();
  
  btnStar = new Button(20, 40, 10, color(255, 193, 37), color(255, 165, 0), "Star");
  btnPlanet = new Button(20, 70, 10, color(224, 224, 224), color(67, 110, 238), "Planet");

  timeline = new Timeline();

  sim = new GravitySimulation();

  sun = new Star(10000, 25, new PVector(300, 500), new PVector(0, 0), 0, "sun");
  planet = new Planet(20, 10, new PVector(400, 500), new PVector(0, 40), "planet");
  planet2 = new Planet(100, 10, new PVector(190, 500), new PVector(0, -40), "planet2");
  
  timeline.registerStatefulObject(sun);
  timeline.registerStatefulObject(planet);
  timeline.registerStatefulObject(planet2);

  controlP5 = new ControlP5(this);  

  btnRewind = controlP5.addButton("btnRewind_OnClick", 0, 800, 20, 50, 20);
  btnRewind.setLabel("Rewind");

  btnPlayPause = controlP5.addButton("btnPlayPause_OnClick", 0, 860, 20, 50, 20);
  btnPlayPause.setLabel("Play");

  btnFastForward = controlP5.addButton("btnFastForward_OnClick", 0, 920, 20, 80, 20);
  btnFastForward.setLabel("Fast Forward");
  
  sliderTimeline = controlP5.addSlider("sliderTimeline_OnClick", 0, 10000, 0, 20, 720, 900, 10);
  sliderTimeline.setLabel("Timeline");
}

void draw()
{
  background(0);
  fill(255);
  bgStars.draw();
  drawFPS();
  
  if (!paused)
    timeline.moveForward();
    
  if(paused)
  {
    btnStar.draw();
    btnPlanet.draw();
    
    fill(50);
    noStroke();
    rect(0, 720, width, (786-720));
  }
  
  if (dragging)
    drawOrbits(timeline.getFutureObjectStates());
  else
    drawOrbits(timeline.getPastObjectStates());
  
  ArrayList objects = timeline.getStatefulObjects();
  for (int i = 0; i < objects.size(); i++)
  {
    CelestialObject obj = (CelestialObject)objects.get(i);
    obj.display();
  }
}

void drawFPS()
{
  text(frameRate, 20, 20);
}

//      _                      ____       _     _ _       
//     | |                    / __ \     | |   (_) |      
//   __| |_ __ __ ___      __| |  | |_ __| |__  _| |_ ___ 
//  / _` | '__/ _` \ \ /\ / /| |  | | '__| '_ \| | __/ __|
// | (_| | | | (_| |\ V  V / | |__| | |  | |_) | | |_\__ \
//  \__,_|_|  \__,_| \_/\_/   \____/|_|  |_.__/|_|\__|___/
public void drawOrbits(ArrayList alObjectsArchive)
{
  ArrayList alPrevPos = new ArrayList();

//  for (int i = timeline.getTimeIdx(); i >= 0 && i > (timeline.getTimeIdx() - 1 - 100); i--)
  for (int i = 0; i < alObjectsArchive.size(); i++)
  {
    ArrayList objects = (ArrayList)alObjectsArchive.get(i);
    for (int j = 0; j < objects.size(); j++)
    {
      CelestialObject obj = (CelestialObject)objects.get(j);
      PVector pos = obj.getPosition();

      stroke(obj.getOrbitColor());

      if (alPrevPos.size() == objects.size())
      {
        PVector prevPos = (PVector)alPrevPos.get(j);
        line(prevPos.x, prevPos.y, pos.x, pos.y);
        alPrevPos.set(j, pos);
      }
      else
        alPrevPos.add(pos);
    }
  }
}

//  ______                _     _    _                 _ _               
// |  ____|              | |   | |  | |               | | |              
// | |__ __   _____ _ __ | |_  | |__| | __ _ _ __   __| | | ___ _ __ ___ 
// |  __|\ \ / / _ \ '_ \| __| |  __  |/ _` | '_ \ / _` | |/ _ \ '__/ __|
// | |____\ V /  __/ | | | |_  | |  | | (_| | | | | (_| | |  __/ |  \__ \
// |______|\_/ \___|_| |_|\__| |_|  |_|\__,_|_| |_|\__,_|_|\___|_|  |___/
//                                                                       
//
public void btnPlayPause_OnClick(int theValue)
{
  paused = !paused;

  if (paused)
    btnPlayPause.setLabel("Play");
  else
    btnPlayPause.setLabel("Pause");
}

public void btnFastForward_OnClick(int theValue)
{
  timeline.moveForward();
}

public void btnRewind_OnClick(int theValue)
{
  timeline.moveBackward();
}

public void sliderTimeline_OnClick(int theValue)
{
  println(theValue + "-" + timeline.getTimeIdx());
  if(!dragging && !rightClick)
    timeline.move(theValue - timeline.getTimeIdx());
}


public void mouseDragged()
{
  if (paused)
  {
    ArrayList objects = timeline.getStatefulObjects();
    for (int i = 0; i < objects.size(); i++)
    {
      CelestialObject obj = (CelestialObject)objects.get(i);
      if (obj.isMouseOver())
      {
        dragging = true;
        PVector pos = obj.getPosition();
        pos.x = mouseX;
        pos.y = mouseY;
        
//        println(pos.x + "," + pos.y);
        timeline.reset();
//        timeline.setCurrentState(objects);
        break;
      }
      
      if (obj.getClass() == Planet.class)
      {
        VelocityVector vec = ((Planet)obj).getVelocityVector();
        if (vec.isMouseOver())
        {
          dragging = true;
          
          PVector pos = obj.getPosition();
          PVector velocity = obj.getVelocity();
          
          velocity.x = mouseX - pos.x;
          velocity.y = mouseY - pos.y;
          
          vec.update(pos, velocity);
          
          timeline.reset();
          
          break;
        }
      }
    }
  }
}

public void mouseReleased()
{
  if (dragging)
    dragging = false;
}

public void mouseClicked()
{
  ArrayList objects = timeline.getStatefulObjects();
  for (int i = 0; i < objects.size(); i++)
  {
    CelestialObject obj = (CelestialObject)objects.get(i);
    if (obj.isMouseOver())
    {
      if (mouseButton == RIGHT || (mouseButton == LEFT && keyPressed && keyCode == 17))
      {
        rightClick = true;
        timeline.unregisterStatefulObject(obj);
        timeline.reset();
        rightClick = false;
        break;
      }
    }
  }
  
  // Check if the click is on the Create Star or Create Planet buttons
  if (btnStar.isMouseOver())
  {
    Star star = new Star(10000, 25, new PVector(300, 500), new PVector(0, 0), 0, "sun" + (timeline.getStarsCount() + 1));
    timeline.registerStatefulObject(star);
  }
  
  if (btnPlanet.isMouseOver())
  {
    Planet planet = new Planet(100, 10, new PVector(150, 500), new PVector(0, -40), "planet" + (timeline.getPlanetsCount() + 1));
    timeline.registerStatefulObject(planet);
  }
}


//  ____             _                                    _    _____ _                  
// |  _ \           | |                                  | |  / ____| |                 
// | |_) | __ _  ___| | __ __ _ _ __ ___  _   _ _ __   __| | | (___ | |_  __ _ _ __ ___ 
// |  _ < / _` |/ __| |/ // _` | '__/ _ \| | | | '_ \ / _` |  \___ \| __|/ _` | '__/ __|
// | |_) | (_| | (__|   <| (_| | | | (_) | |_| | | | | (_| |  ____) | |_| (_| | |  \__ \
// |____/ \__,_|\___|_|\_\\__, |_|  \___/ \__,_|_| |_|\__,_| |_____/ \__|\__,_|_|  |___/
//                         __/ |                                                        
//                        |___/                                                         
class BackgroundStars
{
  int[][] starPoints = new int[400][2];
  
  BackgroundStars()
  {
    //setting star co-ordinates
    for(int i=0;i<400;i++)
    {
      starPoints[i][0]=int(random(2,1024));
      starPoints[i][1]=int(random(2,720));
    }
  }
  
  void draw()
  {
    pushMatrix();
    stroke(200);
    strokeWeight(1);
    
    for(int i = 0; i < 400; i++)
    {
      point(starPoints[i][0], starPoints[i][1]);
    }
    
    popMatrix();
  }
}

//  ____        _   _               
// |  _ \      | | | |              
// | |_) |_   _| |_| |_  ___  _ __  
// |  _ <| | | | __| __|/ _ \| '_ \ 
// | |_) | |_| | |_| |_| (_) | | | |
// |____/ \__,_|\__|\__|\___/|_| |_|
//                                  
//
// Circular buttons used for adding new stars and planets
class Button
{
  int x, y, rad;
  color c1, c2, currentc;
  String name;
  
  Button(int X, int Y, int radius, color colour, color overcolour, String bname)
  {
    x = X;
    y = Y;
    rad = radius;
    c1 = colour;
    c2 = overcolour;
    name = bname;
    currentc = c1;
  }
  
  public void draw()
  {
    pushMatrix();
    pushStyle();
    
    if(this.isMouseOver())
       drawLabel();
       
    stroke(100);
    strokeWeight(2);
    fill(currentc);
    
    ellipse(x, y, rad*2, rad*2);  
    
    popStyle();
    popMatrix();
  }
  
  public void drawLabel()
  {
    pushStyle();
    fill(c1); 
    text(name, x + rad + rad/2, y + rad/2);  
    popStyle();
  }
  
  public boolean isMouseOver()
  {
    float disX = x - mouseX;
    float disY = y - mouseY;
    
    if(sqrt(sq(disX) + sq(disY)) < rad ) 
    { 
      return true;
    } 
    else 
    {
      return false;
    }
  }  
}

//
//  _______ _                _ _            
// |__   __(_)              | (_)           
//    | |   _ _ __ ___   ___| |_ _ __   ___ 
//    | |  | | '_ ` _ \ / _ \ | | '_ \ / _ \
//    | |  | | | | | | |  __/ | | | | |  __/
//    |_|  |_|_| |_| |_|\___|_|_|_| |_|\___|
//                                          
// This class maintains the timeline in which the whole system exists, i.e. it keeps track of the state of the system at each point in
// time, thus allowing the user to go forward and backward in time
class Timeline
{
  int intTimeIdx;  // the current point in time
  ArrayList alObjectStateArchive;  // the state of the system at all previous points in time
  ArrayList alStatefulObjects;  // the current state of the system 
  
  int intStarsCount;
  int intPlanetsCount;
  
  public Timeline()
  {
    intTimeIdx = -1;
    alObjectStateArchive = new ArrayList();
    alStatefulObjects = new ArrayList();
  }
  
  public int getStarsCount()
  {
    return intStarsCount;
  }
  
  public int getPlanetsCount()
  {
    return intPlanetsCount;
  }
  
  public ArrayList getStatefulObjects()
  {
//    return cloneArrayList((ArrayList)this.alStatefulObjects);
    return this.alStatefulObjects;
  }
  
  public ArrayList getObjectStateArchive()
  {
    return this.alObjectStateArchive;
  }
  
  public ArrayList getPastObjectStates()
  {
    ArrayList alPast = new ArrayList();
    for (int i = intTimeIdx; i > 0 && i > intTimeIdx - 100; i--)
    {
      alPast.add(this.alObjectStateArchive.get(i));
    }
    
    return alPast;
  }
  
  public ArrayList getFutureObjectStates()
  {
    ArrayList alFutureArchive = new ArrayList();
    ArrayList alFutureObjects = cloneArrayList(alStatefulObjects);
    
    for (int i = 0; i < 100; i++)
    {
      sim.calculateForces(alFutureObjects);
    
      alFutureArchive.add(cloneArrayList(alFutureObjects));
    }
    
    return alFutureArchive;
  }
  
  public int getTimeIdx()
  {
    return intTimeIdx;
  }
  
  public void reset()
  {
    intTimeIdx = -1;
    alObjectStateArchive.clear();
    sliderTimeline.setValue(0);
  }
  
  public void registerStatefulObject(CelestialObject obj)
  {
    alStatefulObjects.add(obj);
    
    if (obj.getClass() == Star.class)
      intStarsCount++;
    else
      intPlanetsCount++;
  }
  
  public void unregisterStatefulObject(CelestialObject obj)
  {
    int idx = alStatefulObjects.indexOf(obj);
    if (idx != -1)
    {
      alStatefulObjects.remove(idx);
      
      if (obj.getClass() == Star.class)
        intStarsCount--;
      else
        intPlanetsCount--;
    }
  }
  
  public int moveForward()
  {
    println("forward!");
    intTimeIdx++;
    
    // if the future values have already been calculated, just fetch them instead of calculating them again
    if (alObjectStateArchive.size() > intTimeIdx) 
      setCurrentState(cloneArrayList((ArrayList)alObjectStateArchive.get(intTimeIdx)));
    else
    {
//      println("calculating...");
      sim.calculateForces(alStatefulObjects);
      alObjectStateArchive.add(cloneArrayList(alStatefulObjects));
    }
    
    sliderTimeline.setValue(intTimeIdx);
    
    return intTimeIdx;
  }
  
  public void move(int steps)
  {
    if (steps > 0)
    {
      for (int i = 0; i < steps; i++)
        moveForward();
    }
    else
    {
       for (int i = 0; i < abs(steps); i++)
        moveBackward();
    }
  }
  
  public int moveBackward()
  {
    intTimeIdx--;
    
    if (intTimeIdx < 0)
    {
      intTimeIdx = 0;
    }
    else
    {
//      println("before:" + ((CelestialObject)alStatefulObjects.get(0)).getPosition().x + "," + ((CelestialObject)alStatefulObjects.get(0)).getPosition().y);
      setCurrentState(cloneArrayList((ArrayList)alObjectStateArchive.get(intTimeIdx)));
//      println("before:" + ((CelestialObject)alStatefulObjects.get(0)).getPosition().x + "," + ((CelestialObject)alStatefulObjects.get(0)).getPosition().y);
    }
    
    sliderTimeline.setValue(intTimeIdx);
    
    return intTimeIdx;
  }
  
  public void setCurrentState(ArrayList alState)
  {
    for (int i = 0; i < alStatefulObjects.size(); i++)
    {
      alStatefulObjects.set(i, alState.get(i));
    }
  }
  
  // Does a deepcopy of an array list
  public ArrayList cloneArrayList(ArrayList al)
  {
    ArrayList alNew = new ArrayList(al.size());
    for (int i = 0; i < al.size(); i++)
    {
      alNew.add(((CelestialObject)al.get(i)).clone());
    }
    
    return alNew;
  }
}

// __      __   _            _ _       __      __        _              
// \ \    / /  | |          (_) |      \ \    / /       | |             
//  \ \  / /___| | ___   ___ _| |_ _   _\ \  / /___  ___| |_  ___  _ __ 
//   \ \/ // _ \ |/ _ \ / __| | __| | | |\ \/ // _ \/ __| __|/ _ \| '__|
//    \  /|  __/ | (_) | (__| | |_| |_| | \  /|  __/ (__| |_| (_) | |   
//     \/  \___|_|\___/ \___|_|\__|\__, |  \/  \___|\___|\__|\___/|_|   
//                                  __/ |                               
//                                 |___/                                
//
class VelocityVector
{
  PVector pos;
  PVector velocity;
  
  public VelocityVector(PVector pos, PVector velocity)
  {
    this.pos = pos;
    this.velocity = velocity;
  }
  
  public void draw()
  {
    pushMatrix();

    stroke(255, 0, 0);
    
    float newX = pos.x + this.velocity.x;
    float newY = pos.y + this.velocity.y;
    
    line(pos.x, pos.y, newX, newY);
    
    pushMatrix();
    translate(newX, newY);
    rotate(atan2(this.velocity.y, this.velocity.x) + radians(90));
    triangle(0, 0, -5, 5, 5, 5);
    popMatrix();
    
    pushStyle();
    noFill();
    noStroke();
    ellipse(newX, newY, 10, 10);
    popStyle();
      
    popMatrix();
  }
  
  public void update(PVector pos, PVector velocity)
  {
    this.pos = pos;
    this.velocity = velocity;
  }
  
  public boolean isMouseOver()
  {
    float arrowPosX = this.pos.x + this.velocity.x;
    float arrowPosY = this.pos.y + this.velocity.y;

    float disX = arrowPosX - mouseX;
    float disY = arrowPosY - mouseY;
    
    if(sqrt(sq(disX) + sq(disY)) < 10) 
    { 
      return true;
    } 
    else 
    {
      return false;
    }
  }
}

//   _____      _          _   _       _  ____  _     _           _   
//  / ____|    | |        | | (_)     | |/ __ \| |   (_)         | |  
// | |      ___| | ___ ___| |_ _  __ _| | |  | | |__  _  ___  ___| |_ 
// | |     / _ \ |/ _ | __| __| |/ _` | | |  | | '_ \| |/ _ \/ __| __|
// | |____|  __/ |  __|__ \ |_| | (_| | | |__| | |_) | |  __/ (__| |_ 
//  \_____|\___|_|\___|___/\__|_|\__,_|_|\____/|_.__/| |\___|\___|\__|
//                                                  _/ |              
//                                                 |__/               
abstract class CelestialObject implements Cloneable
{
  int mass;
  float radius;
  PVector position;
  PVector velocity;
  PVector acceleration;
  String strName;
  color orbitColor;
  
  ArrayList alForces;

  public CelestialObject(int mass, float radius, PVector position, PVector initialVelocity, String strName)
  {
    this.mass = mass;
    this.radius = radius;
    this.position = position;
    this.velocity = initialVelocity;
    this.acceleration = new PVector(0, 0);
    this.strName = strName;
    this.orbitColor = color(random(255), random(255), random(255));
    
    this.alForces = new ArrayList();
  }
  
  public CelestialObject(int mass, float radius, PVector position, PVector initialVelocity, String strName, color orbitColor)  
  {
    this(mass, radius, position, initialVelocity, strName);
    this.orbitColor = orbitColor;
  }

  public CelestialObject(CelestialObject other)
  {
    this(other.mass, other.radius, 
    new PVector(other.position.x, other.position.y), 
    new PVector(other.velocity.x, other.velocity.y), other.strName);
  }
  
  public void clearForces()
  {
    alForces = new ArrayList();
  }
  
  public void addForce(PVector pv)
  {
    this.alForces.add(pv);
  }
  
  public ArrayList getForces()
  {
    return this.alForces;
  }
  
  public String getName()
  {
    return strName;
  }
  
  public color getOrbitColor()
  {
    return this.orbitColor;
  }

  public void setAcceleration(PVector acceleration)
  {
    this.acceleration = acceleration;
    
    PVector vel = this.getVelocity();
    vel.add(new PVector(acceleration.x/6, acceleration.y/6));
    
    this.setVelocity(vel);
    position.add(velocity);
  }

  public void setPosition(PVector position)
  {
    this.position = position;
  }

  public int getMass()
  {
    return this.mass;
  }

  public PVector getPosition()
  {
    return this.position;
  }
  
  public float getRadius()
  {
    return this.radius;
  }
  
  // Only called when the velocity vector is manipulated
  public void setVelocity(PVector vel)
  {
    this.velocity = vel;
  }
  
  public PVector getVelocity()
  {
    return this.velocity;
  }

  public PVector getAcceleration()
  {
    return this.acceleration;
  }

  public void update()
  {

  }
  
    
  public boolean isMouseOver()
  {
    float disX = position.x - mouseX;
    float disY = position.y - mouseY;
    
    if(sqrt(sq(disX) + sq(disY)) < radius ) 
    {
      return true;
    } 
    else 
    {
      return false;
    }
  }

  public abstract void display();
  
  private float scaleValue(float val)
  {
    float x = 5 + val/100;
    if (x > 30)
      x = 30;
    
    return x;
  }
  
  private PVector getForceLengths(PVector force)
  {

    float vectorLengthX = 0;
    float vectorLengthY = 0;
    
    float ratio = force.y/force.x;
    
    if (abs(force.x) > abs(force.y))
    {
      vectorLengthX = scaleValue(abs(force.x))*(abs(force.x)/force.x);
      vectorLengthY = vectorLengthX * ratio;
    }
    else
    {
      vectorLengthY = scaleValue(abs(force.y))*(abs(force.y)/force.y);
      vectorLengthX = vectorLengthY / ratio;
    }
    
    return new PVector(vectorLengthX, vectorLengthY);
  }
  
  public void drawForceVectors()
  {
    // draw force vectors
      float totalForceX = 0;
      float totalForceY = 0;
      
      for (int i = 0; i < this.alForces.size(); i++)
      {
        PVector f = (PVector)this.alForces.get(i);
        stroke(255, 0, 0);
        
//        println(strName + " " + f.x + "," + f.y);
        
        PVector vectorLengths = getForceLengths(new PVector(f.x, f.y));
        
        line(this.position.x, this.position.y, this.position.x + vectorLengths.x, this.position.y + vectorLengths.y);
        totalForceX += f.x;
        totalForceY += f.y;
      }
      
      stroke(0, 255, 0);
      PVector vectorLengths = getForceLengths(new PVector(totalForceX, totalForceY));
      line(this.position.x, this.position.y, this.position.x + vectorLengths.x, this.position.y + vectorLengths.y);
  }

  public CelestialObject clone()
  {
    try 
    {
      CelestialObject obj = (CelestialObject) super.clone();
  
      obj.position = new PVector(obj.position.x, obj.position.y);
      obj.velocity = new PVector(obj.velocity.x, obj.velocity.y);
      obj.acceleration = new PVector(obj.acceleration.x, obj.acceleration.y);
      obj.alForces = cloneArrayList(obj.alForces);
  
      return obj;
    }
    catch (final CloneNotSupportedException ex) 
    {
      throw new AssertionError();
    }
  }
  
  // Does a deepcopy of an array list
  public ArrayList cloneArrayList(ArrayList al)
  {
    ArrayList alNew = new ArrayList(al.size());
    for (int i = 0; i < al.size(); i++)
    {
      PVector pv = (PVector)al.get(i);
      alNew.add(new PVector(pv.x, pv.y));
    }
    
    return alNew;
  }
}

//   _____ _              
//  / ____| |             
// | (___ | |_  __ _ _ __ 
//  \___ \| __|/ _` | '__|
//  ____) | |_| (_| | |   
// |_____/ \__|\__,_|_|   
class Star extends CelestialObject implements Cloneable
{
  int heat;

  public Star(int mass, float radius, PVector position, PVector initialVelocity, int heat, String strName)
  {
    super(mass, radius, position, initialVelocity, strName);
    this.heat = heat;
  }

  public Star(Star other)
  {
    super(other);
    this.heat = other.heat; 
  }


  public void display()
  {
    pushMatrix();
    
    noStroke();
    
    if (paused && isMouseOver())
      fill(127);
    else
      fill(255);
      
    ellipse(position.x, position.y, radius*2, radius*2);
    
    if (paused)
    {
      fill(255, 0, 0);
      noStroke();
      float handleRadius = radius/10;
      if (handleRadius < 2)
        handleRadius = 2;
        
      ellipse(position.x, position.y, handleRadius*2, handleRadius*2);
    
      drawForceVectors();
    }
    popMatrix();
  }

  public Star clone()
  {
    Star obj = (Star) super.clone();
    return obj;
  }
}

//  _____  _                  _   
// |  __ \| |                | |  
// | |__) | | __ _ _ __   ___| |_ 
// |  ___/| |/ _` | '_ \ / _ \ __|
// | |    | | (_| | | | |  __/ |_ 
// |_|    |_|\__,_|_| |_|\___|\__|
class Planet extends CelestialObject implements Cloneable
{
  int density = 10;
  VelocityVector velocityVector;

  public Planet(int mass, float radius, PVector position, PVector initialVelocity, String strName)
  {
    super(mass, radius, position, initialVelocity, strName);
    velocityVector = new VelocityVector(this.position, this.velocity);
  }
  
  public VelocityVector getVelocityVector()
  {
    return this.velocityVector;
  }
  
  public void setVelocity(PVector vel)
  {
    super.setVelocity(vel);
    this.velocityVector.update(position, vel);
  }
  
  public void display()
  {
    pushMatrix();
    
    noStroke();
    
    if (paused && isMouseOver())
      fill(127);
    else
      fill(255);
    
    ellipse(position.x, position.y, radius*2, radius*2);
    
    if (paused)
    {
      fill(255, 0, 0);
      float handleRadius = radius/10;
      if (handleRadius < 2)
        handleRadius = 2;
        
      ellipse(position.x, position.y, handleRadius*2, handleRadius*2);
      
      this.velocityVector.draw();
      
//      drawForceVectors();
    }
    
    popMatrix();
  }

  public Planet clone()
  {
    Planet obj = (Planet) super.clone();
    obj.velocityVector = new VelocityVector(obj.position, obj.velocity);
    return obj;
  }
}

//   _____                 _ _          _____ _                 _       _   _             
//  / ____|               (_) |        / ____(_)               | |     | | (_)            
// | |  __ _ __ __ ___   ___| |_ _   _| (___  _ _ __ ___  _   _| | __ _| |_ _  ___  _ __  
// | | |_ | '__/ _` \ \ / / | __| | | |\___ \| | '_ ` _ \| | | | |/ _` | __| |/ _ \| '_ \ 
// | |__| | | | (_| |\ V /| | |_| |_| |____) | | | | | | | |_| | | (_| | |_| | (_) | | | |
//  \_____|_|  \__,_| \_/ |_|\__|\__, |_____/|_|_| |_| |_|\__,_|_|\__,_|\__|_|\___/|_| |_|
//                                __/ |                                                   
//                               |___/                                                    
class GravitySimulation
{
  //  double G = 6.67482e-11;
  float G = 6.67482e1;
//  float G = 16.67;

  public GravitySimulation()
  {
    
  }

  void calculateForces(ArrayList objects)
  {
    for (int i = 0; i < objects.size(); i++)
    {
      CelestialObject obj = (CelestialObject)objects.get(i);
      ArrayList forces = obj.getForces();
      float totalForceX = 0;
      float totalForceY = 0;
      
      for (int j = 0; j < forces.size(); j++)
      {
        totalForceX += ((PVector)forces.get(j)).x;
        totalForceY += ((PVector)forces.get(j)).y;
      }
      
      PVector newAccel = new PVector(totalForceX/obj.getMass(), totalForceY/obj.getMass());
      
      obj.setAcceleration(newAccel);
    }
    
    for (int i = 0; i < objects.size(); i++)
    {
      CelestialObject obj1 = (CelestialObject)objects.get(i);
      float forceX = 0;
      float forceY = 0;
      obj1.clearForces();
      
      // We are assuming Stars are stationary, so don't calculate forces acting ON stars
      if (obj1.getClass() == Star.class)
      {
//        println(obj1.getVelocity());
        continue;
      }
  
      for (int j = 0; j < objects.size(); j++)
      {  
        CelestialObject obj2 = (CelestialObject)objects.get(j);
  
        if (i == j)
          continue;
  
        PVector pvDistance = PVector.sub(obj2.getPosition(), obj1.getPosition());
        //    println("distance: x:" + pvDistance.x + " y:" + pvDistance.y);
        float distance = sqrt(sq(pvDistance.y) + sq(pvDistance.x));
        float angle = degrees(atan2(pvDistance.y, pvDistance.x));
  
        float force = (G * obj1.getMass() * obj2.getMass())/sq(distance);
        forceX = force * cos(radians(angle));
        forceY = force * sin(radians(angle));
//        println("FORCES on " + obj1.getName() + ":" + forceX + "," + forceY);
        obj1.addForce(new PVector(forceX, forceY));
      }
    }
  }
}

//  _    _ _   _ _ 
// | |  | | | (_) |
// | |  | | |_ _| |
// | |  | | __| | |
// | |__| | |_| | |
//  \____/ \__|_|_|
static class Util
{
  // Does a deepcopy of an array list
  public static ArrayList cloneArrayList(ArrayList al)
  {
    ArrayList alNew = new ArrayList(al.size());
    for (int i = 0; i < al.size(); i++)
    {
      alNew.add(((CelestialObject)al.get(i)).clone());
    }
    
    return alNew;
  }
}


