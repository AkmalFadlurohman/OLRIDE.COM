package com.olride.OjolServices;

import javax.jws.WebMethod;
import javax.jws.WebService;
import javax.xml.namespace.QName;
import javax.xml.ws.Service;
import javax.jws.soap.SOAPBinding;
import javax.jws.soap.SOAPBinding.Style;
import java.util.*;

@WebService
@SOAPBinding(style = Style.RPC)

public interface LocationManagerInterface {
	
	@WebMethod String[] retrieveLocation(int driverID);
	@WebMethod void addLocation(int driverID,String location);
	@WebMethod void editLocation(int driverID,String oldLocation,String newLocation);
	@WebMethod void delLocation(int driverID,String oldLocation);
	@WebMethod int[] getAvailableDrivers(String pickLoc);
}
