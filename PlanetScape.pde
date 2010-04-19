import java.util.*;
import controlP5.*;

ControlP5 controlP5;

GravitySimulation sim;
Star sun;
Planet planet;
Planet planet2;
ArrayList orbitPositions;

controlP5.Button btnRewind;
controlP5.Button btnPlayPause;
controlP5.Button btnFastForward;

boolean paused;

void setup()
{
  size(1000, 1000);
  background(0);
  frameRate(30);
  smooth();
  
  orbitPositions = new ArrayList();
  
  sim = new GravitySimulation();
  
  sun = new Star(800, 25, new PVector(500, 500), new PVector(0, 0), 0);
  planet = new Planet(10, 10, new PVector(700, 500), new PVector(0, -20));
  planet2 = new Planet(50, 10, new PVector(150, 500), new PVector(0, -10));
  
  sim.add(sun);
  sim.add(planet);
  sim.add(planet2);
  
  controlP5 = new ControlP5(this);
  
  btnRewind = controlP5.addButton("btnRewind_OnClick", 0, 800, 20, 50, 20);
  btnRewind.setLabel("Rewind");
  
  btnPlayPause = controlP5.addButton("btnPlayPause_OnClick", 0, 860, 20, 50, 20);
  btnPlayPause.setLabel("Pause");
  
  btnFastForward = controlP5.addButton("btnFastForward_OnClick", 0, 920, 20, 80, 20);
  btnFastForward.setLabel("Fast Forward");
}

void draw()
{
  background(0);
//  stroke(255);
//  fill(255);

  if (! paused)
    sim.update();
  
  fill(255);
  sun.display();
  planet.display();
  planet2.display();
  
//  for (int i = 0; i < orbitPositions.size(); i++)
//  {
//    PVector pos = (PVector)orbitPositions.get(i);
//    fill(255, 0, 0);
//    ellipse(pos.x, pos.y, 10, 10);
////    println(">>>" + pos.x + "," + pos.y);
//  }
//  fill(255);
  
//  println(orbitPositions.size());

  println(orbitPositions.size());
}

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
  for (int i = 0; i < 1; i++)
  {
    sim.update();
  }
}

public void btnRewind_OnClick(int theValue)
{
  int previousFrame = frameCount - 1;
  Hashtable htObjs = (Hashtable)orbitPositions.get(previousFrame);
  Enumeration e = htObjs.keys();
 
  //iterate through Hashtable keys Enumeration
  while(e.hasMoreElements())
  {
    CelestialObject obj = (CelestialObject)e.nextElement();
    PVector prevPos = (PVector)htObjs.get(obj);
    
    obj.setPosition(prevPos);
  }
}

abstract class CelestialObject
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
}

class Star extends CelestialObject
{
  int heat;
  
  public Star(int mass, int radius, PVector position, PVector initialVelocity, int heat)
  {
    super(mass, radius, position, initialVelocity);
    this.heat = heat;
  }
  
  public void display()
  {
    ellipse(position.x, position.y, radius*2, radius*2);
  }
}

class Planet extends CelestialObject
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
}

class GravitySimulation
{
//  double G = 6.67482e-11;
  float G = 6.67482e1;  
  ArrayList objects;
  
  public GravitySimulation()
  {
    this.objects = new ArrayList();
  }
  
  void add(CelestialObject obj)
  {
    this.objects.add(obj);
  }
  
  void update()
  {
    Hashtable htObjs = new Hashtable();
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
//        println("distance: x:" + pvDistance.x + " y:" + pvDistance.y);
        float distance = sqrt(sq(pvDistance.y) + sq(pvDistance.x));
        float angle = degrees(atan2(pvDistance.y, pvDistance.x));
        
        float force = (G * obj1.getMass() * obj2.getMass())/sq(distance);
        forceX += force * cos(radians(angle));
        forceY += force * sin(radians(angle));
      }
      
      //        println(distance + " " + angle + " " + force + " " + forceX + " " + forceY);
        
        PVector newAccel = new PVector(forceX/obj1.getMass(), forceY/obj1.getMass());
        
        obj1.setAcceleration(newAccel);
        
//        println("POS: x:" + obj1.getPosition().x + " y:" + obj1.getPosition().y);
//        println();
//        orbitPositions.add(obj1.getPosition());

      htObjs.put(obj1, obj1.getPosition());
    }
    
    orbitPositions.add(htObjs);
  }
}

