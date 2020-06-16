//This file was generated from UPPAAL 3.6 Alpha 3, Dec 2005

/*

*/
/* Health check: */

/*

*/
A[](MMI.D<2147483648 && MMI.D2<2147483648 && NAV.D<2147483648 && RAD.D<2147483648 && BusP.D<2147483648)

/*

*/
A[](not deadlock)

/*

*/
/* Binairy search for worst-case response time: */

/*
WCRT
*/
A[](obs==VC3 imply rt<357132)

/*

*/
/* Binairy search for best-case response time: */

/*
BCRT
*/
E<>(obs==VC2 && rt<79075)
