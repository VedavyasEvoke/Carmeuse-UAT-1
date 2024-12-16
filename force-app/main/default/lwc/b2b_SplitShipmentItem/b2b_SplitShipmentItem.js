/**
 * Created by kdreyer on 2/17/21.
 */

import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class B2BSplitShipmentItem extends NavigationMixin(LightningElement) {
    @api splitshipmentitemid;

    onChange(event){
        console.log('firing');
        console.log(event.target.name);
        console.log(event.target.value);
        console.log(event);
        this.shipmentCount[id][event.target.name] = event.target.value;
        console.log(this.shipmentCount[id][event.target.name]);
    }

}