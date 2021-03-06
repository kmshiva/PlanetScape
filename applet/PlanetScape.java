import processing.core.*; 
import processing.xml.*; 

import java.util.*; 
import controlP5.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class PlanetScape extends PApplet {




ControlP5 controlP5;

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

boolean drawVectors;

public void setup()
{
  size(1024, 768);
  background(0);
  frameRate(30);
  smooth();
  
  drawVectors = false;
  
  paused = true;

  timeline = new Timeline();

  sim = new GravitySimulation();

  sun = new Star(5000, 25, new PVector(300, 500), new PVector(0, 0), 0, "sun");
  planet = new Planet(10, 10, new PVector(500, 500), new PVector(0, 40), "planet");
  planet2 = new Planet(50, 10, new PVector(150, 500), new PVector(0, -40), "planet2");
  
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

public void draw()
{
  background(0);
  fill(255);
  
  if (!paused)
    timeline.moveForward();
  
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

public void drawOrbits(ArrayList alObjectsArchive)
{
//  println("SIZE:" + alObjectsArchive.size());
//  ArrayList alObjectsArchive = timeline.getObjectStateArchive();
  ArrayList alPrevPos = new ArrayList();
  ArrayList alColors = new ArrayList();
  alColors.add(color(255, 0, 0));
  alColors.add(color(255, 255, 0));
  alColors.add(color(255, 0, 255));
//  for (int i = timeline.getTimeIdx(); i >= 0 && i > (timeline.getTimeIdx() - 1 - 100); i--)
  for (int i = 0; i < alObjectsArchive.size(); i++)
  {
    ArrayList objects = (ArrayList)alObjectsArchive.get(i);
    for (int j = 0; j < objects.size(); j++)
    {
      CelestialObject obj = (CelestialObject)objects.get(j);
//      CelestialObject obj = (CelestialObject)objects.get(1);
      PVector pos = obj.getPosition();
//      stroke(0, 0, 255);
      stroke((Integer)alColors.get(j));
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

// Event Handlers
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
  if(!dragging)
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
        
        timeline.reset();
        timeline.setCurrentState(objects);
        sliderTimeline.setValue(0);
        break;
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
      println(obj.getName() + " clicked!");
      break;
    }
  }
}

// This class maintains the timeline in which the whole system exists, i.e. it keeps track of the state of the system at each point in
// time, thus allowing the user to go forward and backward in time
class Timeline
{
  int intTimeIdx;  // the current point in time
  ArrayList alObjectStateArchive;  // the state of the system at all previous points in time
  ArrayList alStatefulObjects;  // the current state of the system 
  
  public Timeline()
  {
    intTimeIdx = -1;
    alObjectStateArchive = new ArrayList();
    alStatefulObjects = new ArrayList();
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
  }
  
  public void registerStatefulObject(CelestialObject obj)
  {
    alStatefulObjects.add(obj);
  }
  
  public int moveForward()
  {
//    println("forward!");
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

abstract class CelestialObject implements Cloneable
{
  int mass;
  float radius;
  PVector position;
  PVector velocity;
  PVector acceleration;
  String strName;
  
  ArrayList alForces;

  public CelestialObject(int mass, float radius, PVector position, PVector initialVelocity, String strName)
  {
    this.mass = mass;
    this.radius = radius;
    this.position = position;
    this.velocity = initialVelocity;
    this.strName = strName;
    
    this.alForces = new ArrayList();
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

  public void setAcceleration(PVector acceleration)
  {
    this.acceleration = acceleration;
    velocity.add(acceleration);
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

class Planet extends CelestialObject implements Cloneable
{
  int density = 10;

  public Planet(int mass, float radius, PVector position, PVector initialVelocity, String strName)
  {
    super(mass, radius, position, initialVelocity, strName);
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
      
      drawForceVectors();
    }
    
    popMatrix();
  }

  public Planet clone()
  {
    Planet obj = (Planet) super.clone();
    return obj;
  }
}

class GravitySimulation
{
  //  double G = 6.67482e-11;
  float G = 6.67482e1f;  

  public GravitySimulation()
  {
    
  }

  public void calculateForces(ArrayList objects)
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
      
      if (obj1.getClass() == Star.class)
      {
        println(obj1.getVelocity());
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
        
        println();
      }
    }
  }
}

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



  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#FFFFFF", "PlanetScape" });
  }
}
