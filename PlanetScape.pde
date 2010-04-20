import java.util.*;
import controlP5.*;

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

int intSimCtr;

void setup()
{
  size(1000, 1000);
  background(0);
  frameRate(30);
  intSimCtr = 0;
  smooth();

  timeline = new Timeline();

  sim = new GravitySimulation();

  sun = new Star(1800, 25, new PVector(500, 500), new PVector(0, 0), 0);
  planet = new Planet(10, 10, new PVector(700, 500), new PVector(0, -25));
//  planet2 = new Planet(50, 10, new PVector(150, 500), new PVector(0, -10));
  
  timeline.registerStatefulObject(sun);
  timeline.registerStatefulObject(planet);
//  timeline.registerStatefulObject(planet2);

  controlP5 = new ControlP5(this);

  btnRewind = controlP5.addButton("btnRewind_OnClick", 0, 800, 20, 50, 20);
  btnRewind.setLabel("Rewind");

  btnPlayPause = controlP5.addButton("btnPlayPause_OnClick", 0, 860, 20, 50, 20);
  btnPlayPause.setLabel("Pause");

  btnFastForward = controlP5.addButton("btnFastForward_OnClick", 0, 920, 20, 80, 20);
  btnFastForward.setLabel("Fast Forward");
  
  sliderTimeline = controlP5.addSlider("sliderTimeline_OnClick", 0, 10000, 0, 20, 900, 900, 10);
  sliderTimeline.setLabel("Timeline");
}

void draw()
{
  background(0);
  fill(255);

  if (!paused)
    timeline.moveForward();
  
  ArrayList objects = timeline.getStatefulObjects();
  for (int i = 0; i < objects.size(); i++)
  {
    ((CelestialObject)objects.get(i)).display();
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
  timeline.move(theValue - timeline.getTimeIdx());
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
    return cloneArrayList((ArrayList)this.alStatefulObjects);
  }
  
  public int getTimeIdx()
  {
    return intTimeIdx;
  }
  
  public void registerStatefulObject(CelestialObject obj)
  {
    alStatefulObjects.add(obj);
  }
  
  public int moveForward()
  {
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
  
  private void setCurrentState(ArrayList alState)
  {
    for (int i = 0; i < alStatefulObjects.size(); i++)
    {
      alStatefulObjects.set(i, alState.get(i));
    }
  }
  
  // Does a deepcopy of an array list
  private ArrayList cloneArrayList(ArrayList al)
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
  int radius;
  PVector position;
  PVector velocity;
  PVector acceleration;

  public CelestialObject(int mass, int radius, PVector position, PVector initialVelocity)
  {
    this.mass = mass;
    this.radius = radius;
    this.position = position;
    this.velocity = initialVelocity;
  }

  public CelestialObject(CelestialObject other)
  {
    this(other.mass, other.radius, 
    new PVector(other.position.x, other.position.y), 
    new PVector(other.velocity.x, other.velocity.y));
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

  public PVector getAcceleration()
  {
    return this.acceleration;
  }

  public void update()
  {

  }

  public abstract void display();

  public CelestialObject clone()
  {
    try 
    {
    CelestialObject obj = (CelestialObject) super.clone();

    obj.position = new PVector(obj.position.x, obj.position.y);
    obj.velocity = new PVector(obj.velocity.x, obj.velocity.y);
    obj.acceleration = new PVector(obj.acceleration.x, obj.acceleration.y);

    return obj;
    }
    catch (final CloneNotSupportedException ex) 
    {
    throw new AssertionError();
    }
  }
}

class Star extends CelestialObject implements Cloneable
{
  int heat;

  public Star(int mass, int radius, PVector position, PVector initialVelocity, int heat)
  {
    super(mass, radius, position, initialVelocity);
    this.heat = heat;
  }

  public Star(Star other)
  {
    super(other);
    this.heat = other.heat; 
  }

  public void display()
  {
    ellipse(position.x, position.y, radius*2, radius*2);
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

  public Planet(int mass, int radius, PVector position, PVector initialVelocity)
  {
    super(mass, radius, position, initialVelocity);
  }

  public void display()
  {
    ellipse(position.x, position.y, radius*2, radius*2);
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
  float G = 6.67482e1;  

  public GravitySimulation()
  {
    
  }

  void calculateForces(ArrayList objects)
  {
    intSimCtr += 1;

    for (int i = 0; i < objects.size(); i++)
    {
    CelestialObject obj1 = (CelestialObject)objects.get(i);
    float forceX = 0;
    float forceY = 0;

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
      forceX += force * cos(radians(angle));
      forceY += force * sin(radians(angle));
    }

    PVector newAccel = new PVector(forceX/obj1.getMass(), forceY/obj1.getMass());

    obj1.setAcceleration(newAccel);
    }
  }
}


