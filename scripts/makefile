## make res_2.log -f ../scripts/makefile --> for second async fifo design
## make res_1.log -f ../scripts/makefile --> for first async fifo design



RTL = ../rtl
SIM = ../sim
FILES= ${RTL}/random_num_gen.v ${RTL}/fifo_async1.v ${RTL}/fifo_async2.v ${SIM}/fifo_combo_tb.v ${RTL}/g2b.v ${RTL}/b2g.v ${SIM}/fifo_comb_tasks.v

res_1.log: num_gen_out_1.log rtl_out_1.log
	diff -s num_gen_out_1.log rtl_out_1.log > res_1.log
	cat res_1.log

num_gen_out_1.log rtl_out_1.log: lol_1.out
	./lol_1.out
	../scripts/namematch 1
	rm -f num_gen_out.log rtl_out.log

lol_1.out: ${FILES}
	iverilog ${FILES} -DASYNC1 -o lol_1.out

res_2.log: num_gen_out_2.log rtl_out_2.log
	diff -s num_gen_out_2.log rtl_out_2.log > res_2.log
	cat res_2.log

num_gen_out_2.log rtl_out_2.log: lol_2.out
	./lol_2.out
	../scripts/namematch 2
	rm -f num_gen_out.log rtl_out.log

lol_2.out: ${FILES}
	iverilog ${FILES} -o lol_2.out

clean:
	rm -f ./*.log ./*.out ./*.vcd 
	clear
