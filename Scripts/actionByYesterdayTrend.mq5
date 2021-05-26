//+------------------------------------------------------------------+
//|                                                         test.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   string target = "EURUSD";
   double price_trend = SymbolInfoDouble(target, SYMBOL_PRICE_CHANGE);
   Print("Current price compare to Yesterday's close: ", price_trend);
   MqlTradeRequest request = {0};
   MqlTradeResult result = {0};
   MqlTradeCheckResult ch_result = {0};
   request.action = TRADE_ACTION_DEAL;
   request.symbol = target;
   request.volume = 0.1;
   request.type = ORDER_TYPE_BUY;
   request.price = SymbolInfoDouble(target, SYMBOL_ASK);
   request.deviation = 5;
   request.magic = 17236;
   if(price_trend > 0)
   {
      if(OrderCheck(request, ch_result))
      {
         Print("Enough money!");
      }
      else
      {
         Print("Not enought money!");
         PrintFormat("OrderSend error %d", GetLastError());
      }
      if(!OrderSend(request, result))
      {
         PrintFormat("OrderSend error %d", GetLastError());
         Print("retcode: ", result.retcode);
      }
      else
      {
         Print("Sucess Buy!");
      }  
      PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
   }
   else if(price_trend < 0)
   {
      request.type = ORDER_TYPE_SELL;
      if(OrderCheck(request, ch_result))
      {
         Print("Enough money!");
      }
      else
      {
         Print("Not enought money!");
         PrintFormat("OrderSend error %d", GetLastError());
      }
      if(!OrderSend(request, result))
      {
         PrintFormat("OrderSend error %d", GetLastError());
         Print("retcode: ", result.retcode);
      }
      else
      {
         Print("Sucess Sell!");
      }  
      PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);      
   }
  }
//+------------------------------------------------------------------+
