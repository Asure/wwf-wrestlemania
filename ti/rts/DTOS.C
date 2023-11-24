/****************************************************************************/
/*  dtos v6.10                                                              */
/*  Copyright (c) 1991  Texas Instruments Incorporated                      */
/****************************************************************************/
void dtos(double num, register char *buf, int prec)
{
       register int ival;
       register int pow = 0;
       double       max = 0x7FFFFFFF;

       if (num < 0) 
       { 
	     *buf++ = '-'; 
	     num = -num;
       }

       while (num > max) { num /= 10; pow++; }

       buf += ltoa(ival = num, buf);
       num -= ival;

       while (prec--)
       {
	    if (pow-- == 0) *buf++ = '.';
	    *buf++ = (ival = num *= 10) + '0';
	    num -= ival;
       }
       *buf = 0;
}
