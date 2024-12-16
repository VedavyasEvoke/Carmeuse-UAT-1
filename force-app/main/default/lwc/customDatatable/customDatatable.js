import { LightningElement, api, track } from 'lwc';
export default class CustomDatatable extends LightningElement {
    @api tableData;
    @api columns;
    @api keyField;
    @api styling = {};

    get dtData() {
        return this.prepareTableData(this.tableData, this.columns);
    }

    get dtColumns() {
        return this.prepareColumnsData(this.columns);
    }

    @api
    validateData() {
        let status = true;
        this.template.querySelectorAll('[data-required="true"]').forEach(element => {
            console.log(element.value, element.dataset.fieldname);
            element.reportValidity();

            // if one element is invalid, set variable to false
            if (!element.validity.valid) {
                status = false;
            }
        });
        return status;
    }

    prepareColumnsData(columns) {
        let tableColumns = [];
        if (columns) {
            tableColumns = JSON.parse(JSON.stringify(columns));
            tableColumns.forEach(column => {
                if (!(column.style && column.style.th)) {
                    column.style = { th: '' };
                }
            });
        }
        return tableColumns;
    }

    prepareTableData(data, columns) {
        let tableData = [];
        if (data && columns) {
            data.forEach(row => {
                let tableRow = [];
                columns.forEach(column => {
                    let tableRowItem = {
                        keyFieldValue: row[this.keyField],
                        fieldName: column.fieldName,
                        label: column.label,
                        type: 'text', isText: true,
                        readOnly: ((column.editable || row.editable) ? !(column.editable || row.editable) : true),
                        required: ((column.required) ? column.required : false),
                        minValue: column.minValue
                    };

                    if (column.type && column.type.toLowerCase() === 'combobox') {
                        tableRowItem['value'] = (row[column.fieldData] && row[column.fieldData].value) ? row[column.fieldData].value : '';
                        tableRowItem['options'] = (row[column.fieldData] && row[column.fieldData].options) ? row[column.fieldData].options : [];
                    } else if (column.type && column.type.toLowerCase() === 'checkbox') {
                        tableRowItem['value'] = (row[column.fieldName]) ? row[column.fieldName] : false;
                    } else {
                        tableRowItem['value'] = (row[column.fieldName]) ? row[column.fieldName] : '';
                    }

                    if (column.type) {
                        tableRowItem.isText = false;
                        tableRowItem.type = column.type.toLowerCase();
                        let isType = 'is' + tableRowItem.type[0].toUpperCase() + tableRowItem.type.substring(1, tableRowItem.type.length).toLowerCase();
                        tableRowItem[isType] = true;
                    }
                    tableRow.push(tableRowItem);
                });
                tableData.push(tableRow);
            });
        }
        console.log(tableData);
        return tableData;
    }

    handleCellChange(event) {
        let draftValues = [];
        let draftValue = {};
        draftValue[this.keyField] = event.currentTarget.dataset.keyfieldvalue;
        draftValue[event.currentTarget.dataset.fieldname] = (event.target.type === 'checkbox') ? event.target.checked : event.target.value;
        draftValues.push(draftValue);
        const cellchange = new CustomEvent('cellchange', { detail: { draftValues: draftValues } });
        this.dispatchEvent(cellchange);
    }
}