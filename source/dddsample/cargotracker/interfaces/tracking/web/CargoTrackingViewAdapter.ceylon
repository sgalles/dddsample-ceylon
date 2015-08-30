import ceylon.collection {
	ArrayList
}
import ceylon.interop.java {
	JavaList
}
import ceylon.language.meta {
	metatype=type
}

import dddsample.cargotracker.domain.model.cargo {
	Cargo,
	in_port,
	onboard_carrier,
	claimed,
	not_received,
	unknown
}
import dddsample.cargotracker.domain.model.handling {
	HandlingEvent,
	load,
	unload
}

import java.text {
	SimpleDateFormat
}
import java.util {
	JList=List,
	Date
}
shared class CargoTrackingViewAdapter(Cargo cargo, List<HandlingEvent> handlingEvents) {
	
	String formatDate(Date d) => SimpleDateFormat("MM/dd/yyyy hh:mm a z").format(d);
	
	shared JList<HandlingEventViewAdapter> events => let(adapters = handlingEvents.map(HandlingEventViewAdapter)) 
													 JavaList(ArrayList{*adapters});
	
	
	shared String trackingId => cargo.trackingId.idString;
	shared String origin => cargo.origin.name;
	shared String destination => cargo.routeSpecification.destination.name;
	shared String statusText => let(delivery = cargo.delivery) (
								switch(delivery.transportStatus)
									case(in_port) "In port ``delivery.lastKnownLocation.name``"
									case(onboard_carrier) "Onboard voyage ``delivery.currentVoyage.voyageNumber.number``"
									case(claimed) "Claimed"
									case(not_received) "Not received"
									case(unknown) "Unknown"
								);

	
	shared String  nextExpectedActivity 
			=>  let(activity = cargo.delivery.nextExpectedActivity)
				let(type = activity.type)
				let(text = "Next expected activity is to ``metatype(activity.type).declaration.name``")
				let(voyageNumber = activity.voyage?.voyageNumber else "") // TODO yuck, remove 'else ""' here 
				(switch(type)
				case(load) "``text`` cargo onto voyage ``voyageNumber`` in ``activity.location.name``"
				case(unload) "``text`` cargo off of ``voyageNumber`` in ``activity.location.name``"
				else "``text`` cargo in ``activity.location.name``"
				);
		
	shared Boolean misdirected => cargo.delivery.misdirected;
	shared String eta => if(exists eta = cargo.delivery.estimatedTimeOfArrival) 
						 then formatDate(eta)
						 else "?";
	
}

shared class HandlingEventViewAdapter(HandlingEvent handlingEvent){
	
	shared Boolean expected = true;
	shared String description = "HandlingEventViewAdapter-description";
	
}