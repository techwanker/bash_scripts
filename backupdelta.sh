# This will create a file with every file mounted in a format
# That can be used to check an rsync
sudo find / -printf '%m %M %u %g %Y "%P"\n' > /tmp/root.files

