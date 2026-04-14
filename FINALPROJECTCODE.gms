Sets
    p  "Plants"      / CHN, IND /
    m  "Markets"     / EAST, WEST /
    c  "Components"  / BAT, MOT, PCB, CHS /
    s  "Suppliers"   / S1, S2 /
    t  "Time period" / 1*12 /;
    

Table D(m,t) "Demand of market m in time t"
       1   2   3   4   5   6   7   8   9   10  11  12
EAST  300 320 310 330 340 350 360 370 355 340 330 320
WEST  200 220 240 230 250 270 260 280 275 260 240 230 ;

Table Cship(p,m) "Cost of shipment from plant p to market m"
     EAST  WEST
CHN  110   120
IND  135   150 ;

Parameter
    Cap(p)           "Production capacity per plant p in a month"
    Ccomp(c,s,p)     "Component c purchasing cost from supplier s to plant p"
    Cprod(p)         "Cost of production for plant p"
    a(c)             "Components needed per finished product"
    h(p)             "Inventory holding cost per unit"
    pen(m)           "Shortage penalty cost per unit"
    Supply(c,s,p,t)  "Max monthly supply of component c"
    tau_comp(c,s,p)  "Component tariff rate (supplier→plant)"
    tau_fg(p)        "Finished good tariff rate (plant→US)"
    Eship(p,m)       "CO2 emission per shipment"
    Eprod(p)         "CO2 emission per production"
    MakeCost(p)      "Base making cost for tariff calculation";

Cap("CHN") = 600;
Cap("IND") = 400;

Cprod("CHN") = 425;
Cprod("IND") = 550;

Ccomp("BAT","S1","CHN") = 80;   Ccomp("BAT","S2","CHN") = 90;
Ccomp("BAT","S1","IND") = 70;   Ccomp("BAT","S2","IND") = 65;

Ccomp("MOT","S1","CHN") = 60;   Ccomp("MOT","S2","CHN") = 55;
Ccomp("MOT","S1","IND") = 55;   Ccomp("MOT","S2","IND") = 58;

Ccomp("PCB","S1","CHN") = 30;   Ccomp("PCB","S2","CHN") = 29;
Ccomp("PCB","S1","IND") = 28;   Ccomp("PCB","S2","IND") = 32;

Ccomp("CHS","S1","CHN") = 40;   Ccomp("CHS","S2","CHN") = 45;
Ccomp("CHS","S1","IND") = 38;   Ccomp("CHS","S2","IND") = 36;

a("BAT") = 1;
a("MOT") = 1;
a("PCB") = 2;
a("CHS") = 1;

MakeCost(p) = Cprod(p) + SUM((c,s), Ccomp(c,s,p));

h("CHN") = 5;
h("IND") = 5;

pen("EAST") = 5000;
pen("WEST") = 5000;

Loop(t,
    Supply("BAT","S1","CHN",t) = 300;
    Supply("BAT","S2","CHN",t) = 400;
    Supply("BAT","S1","IND",t) = 150;
    Supply("BAT","S2","IND",t) = 100;

    Supply("MOT","S1","CHN",t) = 500;
    Supply("MOT","S2","CHN",t) = 400;
    Supply("MOT","S1","IND",t) = 400;
    Supply("MOT","S2","IND",t) = 350;

    Supply("PCB","S1","CHN",t) = 600;
    Supply("PCB","S2","CHN",t) = 600;
    Supply("PCB","S1","IND",t) = 150;
    Supply("PCB","S2","IND",t) = 100;

    Supply("CHS","S1","CHN",t) = 600;
    Supply("CHS","S2","CHN",t) = 600;
    Supply("CHS","S1","IND",t) = 200;
    Supply("CHS","S2","IND",t) = 300;
);

*-------------------------------------------------*
* Supplier Disruption Scenario: 
* India loses 40% of BAT supply in Months may, june & july
*-------------------------------------------------*

$ontext
Loop(t$(ord(t)>=5 and ord(t)<=7),
    Supply("BAT","S1","CHN",t) = 0.6 * Supply("BAT","S1","CHN",t);
    Supply("BAT","S2","CHN",t) = 0.6 * Supply("BAT","S2","CHN",t);
    Supply("PCB","S1","CHN",t) = 0.3 * Supply("PCB","S1","CHN",t);
    Supply("PCB","S2","CHN",t) = 0.3 * Supply("PCB","S2","CHN",t);
);
$offtext

tau_comp("BAT","S1","CHN") = 0.12;
tau_comp("BAT","S2","CHN") = 0.15;
tau_comp("BAT","S1","IND") = 0.05;
tau_comp("BAT","S2","IND") = 0.03;

tau_comp("MOT","S1","CHN") = 0.10;
tau_comp("MOT","S2","CHN") = 0.075;
tau_comp("MOT","S1","IND") = 0.04;
tau_comp("MOT","S2","IND") = 0.06;

tau_comp("PCB","S1","CHN") = 0.08;
tau_comp("PCB","S2","CHN") = 0.10;
tau_comp("PCB","S1","IND") = 0.03;
tau_comp("PCB","S2","IND") = 0.05;

tau_comp("CHS","S1","CHN") = 0.09;
tau_comp("CHS","S2","CHN") = 0.12;
tau_comp("CHS","S1","IND") = 0.04;
tau_comp("CHS","S2","IND") = 0.06;

tau_fg("CHN") = 0.25;
tau_fg("IND") = 0.10;

*---------------------------------------------------------------*
* EMISSIONS
*---------------------------------------------------------------*

Eship("CHN","EAST") = 0.25;  Eship("CHN","WEST") = 0.20;
Eship("IND","EAST") = 0.15;  Eship("IND","WEST") = 0.12;

Eprod("CHN") = 0.30;
Eprod("IND") = 0.25;


Scalar
    Emax "Annual emission limit" /4000/
    CO   "Carbon price per ton of CO2" /20/;

*===============================================================*
*                     DECISION VARIABLES
*===============================================================*
Variables
    q(p,t)     "Units produced"
    x(p,m,t)   "Units shipped"
    y(c,s,p,t) "Components purchased"
    I(p,t)     "Inventory"
    B(m,t)     "Unmet demand"
    z          "Total cost";

Positive Variables q, x, y, I, B;

Equations
    DemandSatisfaction(m,t)     "Demand constraints"
    InitialBacklog(m)           "Initial backlog"
    ClearBacklog(m)             "clear backlogs"
    InventoryBalance1(p)        "Opening inventory"
    InventoryBalance(p,t)       "Inventory flow"
    PlantCap(p,t)               "Production capacity"
    SupplierAvail(c,s,p,t)      "Supplier limits"
    ComponentRequirement(c,p,t) "BOM requirements"
    Sustainability              "Emission cap"
    Objective                   "Total cost minimization";


Objective..
    z =e= SUM(t,
            SUM(p,       Cprod(p)      * q(p,t))
          + SUM((p,m),   Cship(p,m)    * x(p,m,t))
          + SUM((p,c,s), Ccomp(c,s,p)  * y(c,s,p,t))
          + SUM(p,       h(p)          * I(p,t))
          + SUM(m,       pen(m)        * B(m,t))
          + SUM((p,m),   tau_fg(p)      * MakeCost(p) * x(p,m,t))
          + SUM((c,s,p), tau_comp(c,s,p) * Ccomp(c,s,p) * y(c,s,p,t))
          )
          + CO * ( SUM((p,m,t), Eship(p,m)*x(p,m,t))
                 + SUM((p,t),   Eprod(p)   *q(p,t))
                );

* Rolling Backlog Demand Constraint
DemandSatisfaction(m,t)..
    SUM(p, x(p,m,t)) + B(m,t) =e= D(m,t) + (B(m,t-1)$(ord(t)>1));
    
InitialBacklog(m)..
    B(m,'1') =e= 0;

ClearBacklog(m)..
    B(m,'12') =e= 0;

InventoryBalance1(p)..
    I(p,'1') =e= q(p,'1') - SUM(m, x(p,m,'1'));

InventoryBalance(p,t)$(ord(t) > 1)..
    I(p,t) =e= I(p,t-1) + q(p,t) - SUM(m, x(p,m,t));

PlantCap(p,t).. q(p,t) =l= Cap(p);

ComponentRequirement(c,p,t)..
    SUM(s, y(c,s,p,t)) =e= a(c) * q(p,t);

SupplierAvail(c,s,p,t)..
    y(c,s,p,t) =l= Supply(c,s,p,t);

Sustainability..
    SUM((p,m,t), Eship(p,m) * x(p,m,t))
  + SUM((p,t),   Eprod(p)   * q(p,t))
  =l= Emax;

Model Project /all/;
Solve Project using lp minimizing z;

Display z.l, q.l, x.l, I.l, B.l, y.l;


$ontext
Set tauCHNset /t1*t5/;
Set tauINDset /u1*u4/;

Parameter tauCHNval(tauCHNset), tauINDval(tauINDset);

tauCHNval("t1") = 0.10;
tauCHNval("t2") = 0.15;
tauCHNval("t3") = 0.20;
tauCHNval("t4") = 0.25;
tauCHNval("t5") = 0.30;

tauINDval("u1") = 0.05;
tauINDval("u2") = 0.10;
tauINDval("u3") = 0.15;
tauINDval("u4") = 0.20;

Table TariffResults(tauCHNset, tauINDset) "Total cost";
TariffResults(tauCHNset, tauINDset) = 0;

Loop(tauCHNset,
    Loop(tauINDset,

        tau_fg("CHN") = tauCHNval(tauCHNset);
        tau_fg("IND") = tauINDval(tauINDset);

        Solve Project using lp minimizing z;

        TariffResults(tauCHNset, tauINDset) = z.l;

    );
);

Display TariffResults;

$offtext
