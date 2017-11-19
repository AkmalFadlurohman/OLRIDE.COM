package com.olride.OjolServices;


import com.olride.bean.Order;
import javax.jws.WebMethod;
import javax.jws.WebService;
import javax.xml.namespace.QName;
import javax.xml.ws.Service;
import javax.jws.soap.SOAPBinding;
import javax.jws.soap.SOAPBinding.Style;

@WebService
@SOAPBinding(style = Style.RPC)

public interface OrderManagerInterface {
        @WebMethod public void saveOrder(String destLoc, String pickLoc, int score,  String comment,int driverId, int customerId);
        @WebMethod public void hideOrder(int id, boolean isDriver);
        @WebMethod public Order[] getListOrderCustomer(int customerID);
        @WebMethod public Order[] getListOrderDriver(int driverID);
}
