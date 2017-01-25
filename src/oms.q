targetsz: ()!()
targetw: ()!()
signal: ()!()
opensz: (enlist `)!(enlist 0Ni) / maps symbols to total size of open orders by symbol

oms.sendorder:{
	opensz[x`sym]+:x`size;
	.market.sendorder[x];
 }

oms.cancelorder:{
	opensz[x`sym]-:x`size;
	.market.cancelorder[x];
 }

.oms.upd.targetsz:{
	targetsz[x[`sym]]::x`sz;
	delta:targetsz-opensz;
	if[cnt:count delta:(where delta <>0)#delta;
		oms.sendorder[([] id:.market.genorderids[cnt]; otype:cnt#`mkt; sym:key delta; size: value delta)]; 
	];
 }

.oms.upd.targetw: {
	.lg.tic[];
	/currw:$[0=count .port.w;([sym:`$()]sz:`float$());.port.w];
	targetw:: x[`sym]!x`w;
	price: (key[targetw] union key port.w) # .market.lastpx;
	delta: neg[opensz] + .math.round (targetw - port.w) * port.equity.last % price; / TODO: syms where market price is missing to be excluded from delta (orders)
	if[cnt:count delta:(where 0 < abs delta)#delta;
		oms.sendorder[([] id:.market.genorderids[cnt]; otype:cnt#`mkt; sym:key delta; size: value delta)];
	];
	.lg.toc[`oms.upd.targetw];
 };
.oms.upd.signal: {
	signal[x`sym]::x`signal;
 }
.oms.upd.rebal: {
	.oms.upd.targetw `sym`w!(key d; value d:weight signal); / TODO: 
 }
.oms.upd.fill: {
	opensz[x`sym]-:x`size;
	.port.upd.fill[x];
 }

/
calc.fun.targetw: {
	currw:$[0=count .port.w;([sym:`$()]sz:`float$());.port.w];
	targw:select sym, sz:w from x;
	delta:select last sz, px:last hfill (`getpx;first sym) by sym from targw pj neg currw;
	orders:select sym, size:floor .port.equity*sz%px from delta;
	if[count orders; (neg hbtt) (`.u.upd;`order;value flip orders)];
 }