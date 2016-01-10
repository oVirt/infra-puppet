# The user for Doron Fediuck
class ovirt_infra::user::dfediuck($password = undef) {
  ovirt_infra::user {'dfediuck':
    key      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDCLonrFiW74Hi+H8ENIBv8saDoloY7wD6VzgFIcIEzYThTEAYhhYHTeAlRYPy8iUbw9jVbqhuXntb9DFjVG7Pu5KbdxD/ZAI18PtMOaruHmNNu99bDNjkGlZmyLWbvnZxk8Paeay6bIRZkO7jMYQEe/DVqHPB3ZN/Sbqlq5di1tI8WltNd0kd6jm5ft+p2NVHrWwxewx0bbdUPeDERE7DcPl444neuYCJ+CQDUew3deaqru9jddxRxqErSYJE37D6DZQINPdp6RA7RDF7efdLm+15MCfT7vs+5zUzEd6VlUiyJ1j7qKZHwP9AcSqv7TIHbborbO5B7gwRcjFL5gQln',
    password => $password,
  }
}
