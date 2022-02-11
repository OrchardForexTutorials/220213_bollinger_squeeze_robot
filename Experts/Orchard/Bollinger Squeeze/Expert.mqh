/*

   Bollinger Squeeze
   Expert

   Copyright 2022, Orchard Forex
   https://www.orchardforex.com

*/

/**=
 *
 * Disclaimer and Licence
 *
 * This file is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * All trading involves risk. You should have received the risk warnings
 * and terms of use in the README.MD file distributed with this software.
 * See the README.MD file for more information and before using this software.
 *
 **/

/*
 * Strategy
 *
 * wait for a consolidation of bollinger indicated by
 *    narrowing to inside a specified range
 *    for a minimum specified period
 * Trade on candle close outside the specified range
 *	tp/sl 1:1 from entry at distance of squeeze range
 *
 */

#include "Framework.mqh"

class CExpert : public CExpertBase
{

 private:
 protected:
#ifdef __MQL4__
#define UPPER_BAND MODE_UPPER
#define LOWER_BAND MODE_LOWER
#endif

   int mHandle;

   int                mBandsPeriod;
   double             mBandsDeviation;
   ENUM_APPLIED_PRICE mBandsAppliedPrice;

   int    mSqueezePeriod;
   double mSqueezeRange;

   double mRangeHi;
   double mRangeLo;
   bool   mInRange;

   void Loop();

   double BandsHigh();
   double BandsLow();
   double BandsExtremum( int bufferNumber, int index );

 public:
   CExpert( int bandsPeriod, double bandsDeviation, ENUM_APPLIED_PRICE bandsAppliedPrice,
            int squeezePeriod, int squeezeRangePts, double volume, string tradeComment, int magic );
   ~CExpert();
};

//
CExpert::CExpert( int bandsPeriod, double bandsDeviation, ENUM_APPLIED_PRICE bandsAppliedPrice,
                  int squeezePeriod, int squeezeRangePts, double volume, string tradeComment,
                  int magic )
   : CExpertBase( volume, tradeComment, magic ) {

   mBandsPeriod       = bandsPeriod;
   mBandsDeviation    = bandsDeviation;
   mBandsAppliedPrice = bandsAppliedPrice;

   mSqueezePeriod = squeezePeriod;
   mSqueezeRange  = PointsToDouble( squeezeRangePts );

   mInRange = false;

#ifdef __MQL5__
   mHandle = iBands( mSymbol, mTimeframe, mBandsPeriod, 0, mBandsDeviation, mBandsAppliedPrice );
   if ( mHandle == INVALID_HANDLE )
   {
      mInitResult = INIT_FAILED;
      return;
   }
#endif

   mInitResult = INIT_SUCCEEDED;
}

//
CExpert::~CExpert() {

#ifdef __MQL5__
   IndicatorRelease( mHandle );
#endif
}

//
void CExpert::Loop() {

   if ( !mNewBar )
      return; // Only trades on open of a new bar

   Recount();
   if ( mCount > 0 )
      return; //	Only one trade at a time

   double hi = BandsHigh(); //	Highest band high in period
   double lo = BandsLow();  //	Lowest band low in period

   if ( ( hi - lo ) <= mSqueezeRange )
   {
      mInRange = true; //	Toggle this on
      mRangeHi = ( ( lo + hi + mSqueezeRange ) / 2 );
      mRangeLo = ( ( lo + hi - mSqueezeRange ) / 2 );
   }

   if ( mInRange )
   {
      double close = iClose( mSymbol, mTimeframe, 1 );
      if ( close > mRangeHi )
      { //	Breakout to top
         Trade.Buy( mOrderSize, mSymbol, 0, mRangeLo, close + ( close - mRangeLo ), mTradeComment );
         // Trade.Buy( mOrderSize, mSymbol, 0, mRangeLo, close + mSqueezeRange, mTradeComment );
         // //	Alternative
         mInRange = false;
      }
      if ( close < mRangeLo )
      { //	Breakout to bottom
         Trade.Sell( mOrderSize, mSymbol, 0, mRangeHi, close - ( mRangeHi - close ),
                     mTradeComment );
         // Trade.Sell( mOrderSize, mSymbol, 0, mRangeHi, close - mSqueezeRange, mTradeComment );
         // //	Alternative
         mInRange = false;
      }
   }

   return;
}

//
double CExpert::BandsHigh() {

   return ( BandsExtremum( UPPER_BAND, mSqueezePeriod - 1 ) );
}

double CExpert::BandsLow() {

   return ( BandsExtremum( LOWER_BAND, 0 ) );
}

double CExpert::BandsExtremum( int bufferNumber, int index ) {

   //	Beware in case there are simply not enough bars to generate a result
   //	That would be very unusual unless you set an extremely long
   //	period so I haven't bothered to deal with it here

   double buf[];

#ifdef __MQL5__
   CopyBuffer( mHandle, bufferNumber, 1, mSqueezePeriod, buf );
#endif

#ifdef __MQL4__
   ArrayResize( buf, mSqueezePeriod );
   for ( int i = 1; i <= mSqueezePeriod; i++ )
   {
      buf[i - 1] = iBands( mSymbol, ( int )mTimeframe, mBandsPeriod, mBandsDeviation, 0,
                           mBandsAppliedPrice, bufferNumber, i );
   }
#endif

   ArraySort( buf );
   return ( buf[index] );
}