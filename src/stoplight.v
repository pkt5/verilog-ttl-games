module stoplight(input clk, rst_n, clr_n, hit,
                 output L0, L1, L2, L3, L4, L5, L6, L7, miss, a, b, c, d, e, f,
                        g, ba, bb, bc, bd, be, bf, bg);
  wire over, press, load_n, gt;
  wire s0, s1, s2, s3;

  ctrl  U1 (.clk(clk), .rst_n(rst_n), .hit(hit), .L4(L4), .s3(s3), .s0(s0), .gt(gt),
            .over(over), .press(press), .miss(miss), .load_n(load_n));
  ring  U2 (.clk(clk), .rst_n(rst_n), .over(over),
            .L0(L0), .L1(L1), .L2(L2), .L3(L3), .L4(L4), .L5(L5), .L6(L6), .L7(L7));
  score U3 (.clk(clk), .rst_n(rst_n), .press(press), .L4(L4),
            .s0(s0), .s1(s1), .s2(s2), .s3(s3),
            .a(a), .b(b), .c(c), .d(d), .e(e), .f(f), .g(g));
  best  U4 (.clk(clk), .clr_n(clr_n), .load_n(load_n),
            .s0(s0), .s1(s1), .s2(s2), .s3(s3), .gt(gt),
            .ba(ba), .bb(bb), .bc(bc), .bd(bd), .be(be), .bf(bf), .bg(bg));
endmodule

module ctrl(input clk, rst_n, hit, L4, s3, s0, gt,
            output over, press, miss, load_n);
  wire hit_old_n, miss_n, miss_d, win_n, on, press_n, wrong;

  ic7474 ff (.D1(hit), .CLK1(clk), .PRE1_n(on), .CLR1_n(1'b1), .Q1_n(hit_old_n),
             .D2(miss_d), .CLK2(clk), .PRE2_n(rst_n), .CLR2_n(1'b1), .Q2(miss_n), .Q2_n(miss));
  ic7400 nd (.A1(s3), .B1(s0), .Y1(win_n),
             .A2(miss_n), .B2(win_n), .Y2(over),
             .A3(hit), .B3(hit_old_n), .Y3(press_n),
             .A4(over), .B4(gt), .Y4(load_n));
  ic7402 nr (.A1(over), .B1(over), .Y1(on),
             .A2(press_n), .B2(press_n), .Y2(press),
             .A3(press_n), .B3(L4), .Y3(wrong),
             .A4(miss), .B4(wrong), .Y4(miss_d));
endmodule

module ring(input clk, rst_n, over,
            output L0, L1, L2, L3, L4, L5, L6, L7);
  wire rst, z, z_d;

  ic7404  inv (.A1(rst_n), .Y1(rst), .A2(L7), .Y2(z_d), .A3(z), .Y3(L0),
               .A4(1'b0), .A5(1'b0), .A6(1'b0));
  ic74173 lo  (.CLK(clk), .CLR(rst), .G1_n(over), .G2_n(1'b0),
               .D1(z_d), .D2(L0), .D3(L1), .D4(L2), .Q1(z), .Q2(L1), .Q3(L2), .Q4(L3));
  ic74173 hi  (.CLK(clk), .CLR(rst), .G1_n(over), .G2_n(1'b0),
               .D1(L3), .D2(L4), .D3(L5), .D4(L6), .Q1(L4), .Q2(L5), .Q3(L6), .Q4(L7));
endmodule

module score(input clk, rst_n, press, L4,
             output s0, s1, s2, s3, a, b, c, d, e, f, g);
  ic74163 cnt  (.CLK(clk), .CLR_n(rst_n), .LOAD_n(1'b1), .ENP(press), .ENT(L4),
                .A(1'b0), .B(1'b0), .C(1'b0), .D(1'b0),
                .QA(s0), .QB(s1), .QC(s2), .QD(s3));
  ic7447  disp (.A(s0), .B(s1), .C(s2), .D(s3), .LT_n(1'b1), .BI_n(1'b1), .RBI_n(1'b1),
                .a(a), .b(b), .c(c), .d(d), .e(e), .f(f), .g(g));
endmodule

module best(input clk, clr_n, load_n, s0, s1, s2, s3,
            output gt, ba, bb, bc, bd, be, bf, bg);
  wire b0, b1, b2, b3;

  ic74163 reg4 (.CLK(clk), .CLR_n(clr_n), .LOAD_n(load_n), .ENP(1'b0), .ENT(1'b0),
                .A(s0), .B(s1), .C(s2), .D(s3),
                .QA(b0), .QB(b1), .QC(b2), .QD(b3));
  ic7485  cmp  (.A3(s3), .A2(s2), .A1(s1), .A0(s0), .B3(b3), .B2(b2), .B1(b1), .B0(b0),
                .IAgtB(1'b0), .IAltB(1'b0), .IAeqB(1'b1), .OAgtB(gt));
  ic7447  disp (.A(b0), .B(b1), .C(b2), .D(b3), .LT_n(1'b1), .BI_n(1'b1), .RBI_n(1'b1),
                .a(ba), .b(bb), .c(bc), .d(bd), .e(be), .f(bf), .g(bg));
endmodule
