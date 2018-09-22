
#property strict

#include <stderror.mqh>
#include <stdlib.mqh>

//--- input parameters

input string Password = ""; // Please Enter Your Password

extern double StopLoss = 30;
extern double TakeProfit = 30;
input double   LotSize = 1;

extern int Slippage = 30;
extern int MagicSeed = 1000;
double pips;
int magic;

extern bool UseMovetoBreakEven = false; // Enable Breakeven Function? 
extern int WhenToMoveBreakEven = 10; // How many pips before Breakeven function is triggered?
extern int PipsToLockInBreakEven = 1; // How many pips to lock in for Breakeven function?

extern string Fast_Ma_Settings;
extern int fastMaPeriod = 1;
extern string Methods = "0=SMA, 1=EMA, 2=SMMA, 3=LWMA";
extern int fastMaMethod = 1;
extern string AppliedOptions = "0=Close, 1=Open, 2=High";
extern string AppliedOptions2 = "3=Low, 4=Typical, 5=Weighted Close";
extern int fastMaAppliedTo = 4;
extern int fastMaShift = 0;
//----
extern string Slow_Ma_Settings;
extern int slowMaPeriod = 8;
extern string Methods2 = "0=SMA, 1=EMA, 2=SMMA, 3=LWMA";
extern int slowMaMethod = 1;
extern string AppliedOptions3 = "0=Close, 1=Open, 2=High";
extern string AppliedOptions4 = "3=Low, 4=Typical, 5=Weighted Close";
extern int slowMaAppliedTo = 4;
extern int slowMaShift = 0;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int OnInit()
  {

   magic = MagicNumberGenerator();
   Print("MagicNumber is ",magic);

// Determine what a pip is
   pips=Point; //.00001 or .0001. .001 .01. Point size of the symbol based on your terminal. Newer brokers have 5 digits (non-JPY).  
   if(Digits==3 || Digits==5)
      pips*=10; // pips = pips*10

// Include Checks on Startup
   #include<InitChecks.mqh>
   Comment("Expert Loaded Successfully");
   return(INIT_SUCCEEDED);

  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

   Comment(" ");

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
  
   if(UseMovetoBreakEven)
   MovetoBreakEven();
   
   CheckForSignal();


  }
//+------------------------------------------------------------------+
//| Trigger                                                          |
//+------------------------------------------------------------------+

void CheckForSignal()
  {
   static datetime candletime = 0;
   if(candletime != Time[0]){
      
           
      double currentFast = iMA(NULL,0,fastMaPeriod,fastMaShift,fastMaMethod,fastMaAppliedTo,1);
      double previousFast = iMA(NULL,0,fastMaPeriod,fastMaShift,fastMaMethod,fastMaAppliedTo,2);
      double currentSlow = iMA(NULL,0,slowMaPeriod,slowMaShift,slowMaMethod,slowMaAppliedTo,1);
      double previousSlow = iMA(NULL,0,slowMaPeriod,slowMaShift,slowMaMethod,slowMaAppliedTo,2);
      
      
      if (Hour()==14 && Minute()==00 && currentFast > currentSlow) 
         EnterTrade(OP_BUY);
      else if (Hour()==14 && Minute()==00 && currentFast < currentSlow) 
         EnterTrade(OP_SELL);
         
      candletime=Time[0];
      
      
   }
  }
//+------------------------------------------------------------------+
//| Trade Placing Function                                           |
//+------------------------------------------------------------------+

void EnterTrade(int type)
  {

   double price = 0;  //Selecting the Bid or Ask price if it's a Sell or Buy order respectively. 
   if(type == OP_BUY)
      price = Ask;
   else
      price = Bid;
      
   double sl = 0; 
   double tp = 0;
   
   int err = 0;
     
   int ticket = OrderSend(Symbol(),type,LotSize,price,Slippage,0,0,"Global Unitus Trade",magic,0,Magenta); //Order Send, Order Select and Order Modify
   if(ticket>0)
     {
      if(OrderSelect(ticket,SELECT_BY_TICKET))
        {
         if(OrderType()==OP_SELL)
           {
            sl = OrderOpenPrice()+(StopLoss*pips);
            tp = OrderOpenPrice()-(TakeProfit*pips);
           }
         if(OrderType()==OP_BUY)
           {
            sl = OrderOpenPrice()-(StopLoss*pips);
            tp = OrderOpenPrice()+(TakeProfit*pips);
           }
         if(!OrderModify(ticket,price,sl,tp,0,Magenta)) 
           {
            err=GetLastError();
            Print("Encountered an error during modification!"+(string)err+" "+ErrorDescription(err));
           }
        }
      else
        {//in case it fails to select the order for some reason 
         Print("Failed to Select Order ",ticket);
         err=GetLastError();
         Print("Encountered an error while seleting order "+(string)ticket+" error number "+(string)err+" "+ErrorDescription(err));
        }
     }
   else
     {//in case it fails to place the order and send us back a ticket number.
      err=GetLastError();
      Print("Encountered an error during order placement!"+(string)err+" "+ErrorDescription(err));
      if(err==ERR_TRADE_NOT_ALLOWED)MessageBox("You can not place a trade because \"Allow Live Trading\" is not checked in your options. Please check the \"Allow Live Trading\" Box!","Check Your Settings!");
     }
  }
  
//+------------------------------------------------------------------+
//| Magic Number Generator                                           |
//+------------------------------------------------------------------+
  
  int MagicNumberGenerator()
  {
  
  string mySymbol = StringSubstr(_Symbol,0,6); 
  int pairNumber = 0; 
  int GeneratedNumber =0;  
   	
	     if (mySymbol == "AUDCAD") 	pairNumber=1;
	else if (mySymbol == "AUDCHF") 	pairNumber=2;
	else if (mySymbol == "AUDJPY") 	pairNumber=3;
	else if (mySymbol == "AUDNZD") 	pairNumber=4;
	else if (mySymbol == "AUDUSD") 	pairNumber=5;
	else if (mySymbol == "CADCHF") 	pairNumber=6;
	else if (mySymbol == "CADJPY") 	pairNumber=7;
	else if (mySymbol == "CHFJPY") 	pairNumber=8;
	else if (mySymbol == "EURAUD") 	pairNumber=9;
	else if (mySymbol == "EURCAD") 	pairNumber=10;
	else if (mySymbol == "EURCHF") 	pairNumber=11;
	else if (mySymbol == "EURGBP") 	pairNumber=12;
	else if (mySymbol == "EURJPY") 	pairNumber=13;
	else if (mySymbol == "EURNZD") 	pairNumber=14;
	else if (mySymbol == "EURUSD") 	pairNumber=15;
	else if (mySymbol == "GBPAUD") 	pairNumber=16;
	else if (mySymbol == "GBPCAD") 	pairNumber=17;
	else if (mySymbol == "GBPCHF") 	pairNumber=18;
	else if (mySymbol == "GBPJPY") 	pairNumber=19;
	else if (mySymbol == "GBPNZD") 	pairNumber=20;
	else if (mySymbol == "GBPUSD") 	pairNumber=21;
	else if (mySymbol == "NZDCAD") 	pairNumber=22;
	else if (mySymbol == "NZDJPY") 	pairNumber=23;
	else if (mySymbol == "NZDCHF") 	pairNumber=24;
	else if (mySymbol == "NZDUSD") 	pairNumber=25;
	else if (mySymbol == "USDCAD") 	pairNumber=26;
	else if (mySymbol == "USDCHF") 	pairNumber=27;
	else if (mySymbol == "USDJPY")	pairNumber=28;
  
  GeneratedNumber = MagicSeed + (pairNumber*10) + _Period;
  return (GeneratedNumber);
  
  
  }
  
  //+------------------------------------------------------------------+
  //|   Move to Breakeven Function                                     |
  //+------------------------------------------------------------------+
  
 
  
  void MovetoBreakEven()

  {
      int err = 0;
      
      for(int i=OrdersTotal()-1; i>=0; i--) // e.g., 8 orders open. Goes from zero to seven. Seven is the latest order. OrdersTotal is the number of orders so we need 7 first.  
     {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         {
            if(OrderMagicNumber() == magic)
            
               if(OrderType() == OP_BUY)  //Buy order, get in at the ASK but we need to get out at the BID. 
               {
                  if(Bid-OrderOpenPrice()> WhenToMoveBreakEven*pips) //Is the current price minus open price greater than the size of the breakeven distance set?
                     if(OrderStopLoss() < OrderOpenPrice()) //Is the SL below the open price?
                        if(!OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice()+(PipsToLockInBreakEven*pips),OrderTakeProfit(),0,CLR_NONE))
                           {
                           err=GetLastError();
                           Print("Encountered an error during modification!"+(string)err+" "+ErrorDescription(err));
                           }
               }
     
     
                else if(OrderType() == OP_SELL)  //Sell order, get in at the Bid but we need to get out at the Ask. 
               {
                  if(OrderOpenPrice()-Ask> WhenToMoveBreakEven*pips) 
                     if(OrderStopLoss() > OrderOpenPrice()) 
                        if(!OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice()-(PipsToLockInBreakEven*pips),OrderTakeProfit(),0,CLR_NONE))
                           {
                           err=GetLastError();
                           Print("Encountered an error during modification!"+(string)err+" "+ErrorDescription(err));
                           }
               }
         else
         {//in case it fails to place the order and send us back a ticket number.
         err=GetLastError();
         Print("Encountered an error during order selection in: "__FUNCTION__+"!"+(string)err+" "+ErrorDescription(err));     //FUNCTION prices out the acutal function name "MovetoBreakEven()"
         }
         }
           
   }
 } 
  
//+------------------------------------------------------------------+
