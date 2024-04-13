#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#include <Trade/Trade.mqh>

// buy -> ASK
// sell -> BID
input double volume_param = 1;

class OrderSender
{
   public:
      // constructor
      void OrderSender()
      {
         volume = volume_param;
      }
      
   private:
      double volume;
      CTrade trade;
      
      ENUM_POSITION_TYPE getLastPositionType() {
         int total = PositionsTotal();
         if (total == 0) return -1;
         
         ulong ticket_pos=PositionGetTicket(total-1);
         PositionSelectByTicket(ticket_pos);
         ENUM_POSITION_TYPE type_pos = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         
         return type_pos;
      }
      
   public:
      double getCurrentProfit() {
         int totalPosition = PositionsTotal();
         double profit;
         double totalProfit = 0;
         ulong ticket_pos;
         
         for (int i=0; i<totalPosition; i++) {
            ticket_pos=PositionGetTicket(i);
            PositionSelectByTicket(ticket_pos);
            profit = PositionGetDouble(POSITION_PROFIT);
            totalProfit += profit;
         }
         return totalProfit;
      }
      
      void closeAllPosition() {
         int totalPosition = PositionsTotal();
         ulong ticket_pos;
         
         for (int i=totalPosition-1; i>=0; i--) {
            ticket_pos=PositionGetTicket(i);
            trade.PositionClose(ticket_pos);
         }
         this.volume = volume_param;
      }
      
      
      void buy()
      {
         ENUM_POSITION_TYPE lastPositionType = getLastPositionType();
         
         if(lastPositionType == -1 || lastPositionType == POSITION_TYPE_SELL) {
            PrintFormat("Buying: %s", _Symbol);
            bool orderSucess = trade.Buy(this.volume, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_ASK));
            if (orderSucess) {
               this.volume += volume_param;
            }   
          } else if(lastPositionType == POSITION_TYPE_BUY) {
            PrintFormat("Trend same, do nothing in this peroid!");   
          } else {
            PrintFormat("Error when buy()");
          }
      }
      
      
      void sell()
      {
         ENUM_POSITION_TYPE lastPositionType = getLastPositionType();
         
         if(lastPositionType == 0 || lastPositionType == POSITION_TYPE_BUY) {
            PrintFormat("Selling: %s", _Symbol);
            bool orderSucess = trade.Sell(this.volume, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_BID));
            if (orderSucess) {
               this.volume += volume_param;
            }   
         } else if(lastPositionType == POSITION_TYPE_SELL) {
            PrintFormat("Trend same, do nothing in this peroid!");
         } else {
            PrintFormat("Error when sell()");
         }
      }
};