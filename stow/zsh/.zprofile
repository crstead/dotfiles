export PATH="$HOME/.local/bin:$PATH"
export PATH=$PATH:/usr/local/go/bin

# Start Sway automatically on TTY1
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
	exec sway
fi
