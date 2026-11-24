module reaction(input clk, rst_n, clr_n, start, stop, S3, S2, S1, S0,
                output go, foul, a, b, c, d, e, f, g, ba, bb, bc, bd, be, bf,
                       bg);
  wire n0, n1, n2, n3, start_n, stop_n;
  wire load_n, cnt, run, rco, done_n, keep, rec, lt;
  wire t0, t1, t2, t3;

  keys  U1 (.S3(S3), .S2(S2), .S1(S1), .S0(S0), .start(start), .stop(stop),
            .n3(n3), .n2(n2), .n1(n1), .n0(n0), .start_n(start_n), .stop_n(stop_n));
  ctrl  U2 (.clk(clk), .rst_n(rst_n), .clr_n(clr_n), .start_n(start_n), .stop(stop),
            .stop_n(stop_n), .rco(rco), .t3(t3), .t0(t0), .lt(lt),
            .load_n(load_n), .cnt(cnt), .run(run), .go(go), .foul(foul),
            .done_n(done_n), .keep(keep), .rec(rec));
  timer U3 (.clk(clk), .n3(n3), .n2(n2), .n1(n1), .n0(n0),
            .load_n(load_n), .cnt(cnt), .run(run), .go(go),
            .t0(t0), .t1(t1), .t2(t2), .t3(t3), .rco(rco),
            .a(a), .b(b), .c(c), .d(d), .e(e), .f(f), .g(g));
  best  U4 (.clk(clk), .t0(t0), .t1(t1), .t2(t2), .t3(t3),
            .done_n(done_n), .keep(keep), .rec(rec), .lt(lt),
            .ba(ba), .bb(bb), .bc(bc), .bd(bd), .be(be), .bf(bf), .bg(bg));
endmodule

module keys(input S3, S2, S1, S0, start, stop,
            output n3, n2, n1, n0, start_n, stop_n);
  ic7404 inv (.A1(S3), .Y1(n3), .A2(S2), .Y2(n2), .A3(S1), .Y3(n1), .A4(S0), .Y4(n0),
              .A5(start), .Y5(start_n), .A6(stop), .Y6(stop_n));
endmodule

module ctrl(input clk, rst_n, clr_n, start_n, stop, stop_n, rco, t3, t0, lt,
            output load_n, cnt, run, go, foul, done_n, keep, rec);
  wire A, A_n, go_n, go_d, go_set_n, E, end_d, end_set_n, done, rec_n, rec_d;

  ic7474 ff1 (.D1(load_n), .CLK1(clk), .PRE1_n(1'b1), .CLR1_n(rst_n), .Q1(A), .Q1_n(A_n),
              .D2(go_d), .CLK2(clk), .PRE2_n(1'b1), .CLR2_n(rst_n), .Q2(go), .Q2_n(go_n));
  ic7474 ff2 (.D1(end_d), .CLK1(clk), .PRE1_n(1'b1), .CLR1_n(rst_n), .Q1(E), .Q1_n(run),
              .D2(rec_d), .CLK2(clk), .PRE2_n(clr_n), .CLR2_n(1'b1), .Q2(rec_n), .Q2_n(rec));
  ic7400 nd  (.A1(A_n), .B1(start_n), .Y1(load_n),
              .A2(go_n), .B2(go_set_n), .Y2(go_d),
              .A3(A), .B3(stop), .Y3(end_set_n),
              .A4(run), .B4(end_set_n), .Y4(end_d));
  ic7410 nd3 (.A1(A), .B1(rco), .C1(stop_n), .Y1(go_set_n),
              .A2(go), .B2(t3), .C2(t0), .Y2(cnt),
              .A3(E), .B3(go), .C3(1'b1), .Y3(done_n));
  ic7402 nr  (.A1(run), .B1(go), .Y1(foul),
              .A2(run), .B2(go_n), .Y2(done),
              .A3(rec), .B3(done), .Y3(rec_d),
              .A4(lt), .B4(rec_n), .Y4(keep));
endmodule

module timer(input clk, n3, n2, n1, n0, load_n, cnt, run, go,
             output t0, t1, t2, t3, rco, a, b, c, d, e, f, g);
  wire d0, d1, d2, d3;

  ic74163 cnt4 (.CLK(clk), .CLR_n(1'b1), .LOAD_n(load_n), .ENP(cnt), .ENT(run),
                .A(n0), .B(n1), .C(n2), .D(n3),
                .QA(t0), .QB(t1), .QC(t2), .QD(t3), .RCO(rco));
  ic7408  gate (.A1(t0), .B1(go), .Y1(d0), .A2(t1), .B2(go), .Y2(d1),
                .A3(t2), .B3(go), .Y3(d2), .A4(t3), .B4(go), .Y4(d3));
  ic7447  disp (.A(d0), .B(d1), .C(d2), .D(d3), .LT_n(1'b1), .BI_n(1'b1), .RBI_n(1'b1),
                .a(a), .b(b), .c(c), .d(d), .e(e), .f(f), .g(g));
endmodule

module best(input clk, t0, t1, t2, t3, done_n, keep, rec,
            output lt, ba, bb, bc, bd, be, bf, bg);
  wire b0, b1, b2, b3;

  ic74173 reg4 (.CLK(clk), .CLR(1'b0), .G1_n(done_n), .G2_n(keep),
                .D1(t0), .D2(t1), .D3(t2), .D4(t3), .Q1(b0), .Q2(b1), .Q3(b2), .Q4(b3));
  ic7485  cmp  (.A3(t3), .A2(t2), .A1(t1), .A0(t0), .B3(b3), .B2(b2), .B1(b1), .B0(b0),
                .IAgtB(1'b0), .IAltB(1'b0), .IAeqB(1'b1), .OAltB(lt));
  ic7447  disp (.A(b0), .B(b1), .C(b2), .D(b3), .LT_n(1'b1), .BI_n(rec), .RBI_n(1'b1),
                .a(ba), .b(bb), .c(bc), .d(bd), .e(be), .f(bf), .g(bg));
endmodule
