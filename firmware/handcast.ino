const int trigPin = 9;
const int echoPin = 10;

long duration;
float distance;
float smoothDistance = 0;
const float alpha = 0.3;

void setup() {
  Serial.begin(115200);
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
}

void loop() {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  
  duration = pulseIn(echoPin, HIGH, 30000);
  
  if (duration > 0) {
    distance = (duration * 0.0343) / 2;
    smoothDistance = (alpha * distance) + ((1.0 - alpha) * smoothDistance);
    
    Serial.print("DIST:");
    Serial.println(smoothDistance, 1);
  }
  
  delay(30);
}
