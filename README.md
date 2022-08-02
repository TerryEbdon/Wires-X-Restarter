# Wires-X_Restarter

Wires-X will restart itself once the message is dismissed. This script
restarts the app with minimal delay. All restarts are logged. By default
messages are logged to the console. This can be changed via the configuration
file. Multiple consecutive restarts are handled, with a short delay between
restarts to avoid locking the user out. The Wires-X reboot requests are
typically hours, even days, apart. Under these circumstances the script's
response will be almost instantaneous.
