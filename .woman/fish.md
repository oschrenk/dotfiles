# for loop

```
for i in 1 2 3 4 5
  echo host$i; ssh host$i 'cat /proc/meminfo | grep MemTotal'
end
```
