
GravitySimulation sim;
Star sun;
Planet planet;
Planet planet2;
ArrayList orbitPositions;

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
}

void draw()
{
  background(0);
//  stroke(255);
//  fill(255);
  sim.update();
  
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
    }
  }
}

