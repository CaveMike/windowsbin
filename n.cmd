:loop
@netstat.exe -an > c:\bin\n1.txt
@copy c:\bin\n0.txt + c:\bin\n1.txt c:\bin\n2.txt 1> nul
@sort.exe < c:\bin\n2.txt > c:\bin\n3.txt
@uniq.exe -u c:\bin\n3.txt | sort /+10
@rem sleep 1
@rem goto loop