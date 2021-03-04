------------------------
-- Drives
------------------------

function unmountExternalDrives()
  print("unmount called")
  notify("Unmounting Drives")
  -- escape single quotes like \'
  -- escape backslashes in sed with extra backslash
  os.execute("/usr/sbin/diskutil list | grep -i windows | sed \'s/.*\\(disk[0-9].*\\)/\\1/\' | uniq | xargs -I= /usr/sbin/diskutil unmount =")
end

function mountExternalDrives()
  print("mount called")
  notify("Mounting Drives")
  -- escape single quotes like \'
  -- escape backslashes in sed with extra backslash
  os.execute("/usr/sbin/diskutil list | grep -i windows | sed \'s/.*\\(disk[0-9].*\\)/\\1/\' | uniq | xargs -I= /usr/sbin/diskutil mount =")
end
