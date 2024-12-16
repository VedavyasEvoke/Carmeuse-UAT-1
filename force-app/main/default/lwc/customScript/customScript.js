export function onBeforeCalculate(quote, lines, conn) {
    console.log(quote); console.log(lines); console.log(conn);
    if (lines.length > 0) { return calculateBrandText(quote, lines, conn); }
    return Promise.resolve();
}
function calculateBrandText(quote, lines, conn) {
    let dataSet = {};
    let objFieldMap = {
        SBQQ__Quote__c: { 'Sub_Market__c': 'Market_Segment_Code__c' },
        SBQQ__QuoteLine__c: { 'Plant__c': 'Plant_Code__c' },
        Product2: {
            Composition__c: 'Product_Comp_Code__c',
            Family: 'Product_Family_Code__c',
            Size__c: 'Product_Size_Code__c',
            Product_Type__c: 'Product_Type_Code__c'
        }
    };

    let productIds = []; let plants = new Set(); let productCodes = new Set();
    for (let i = 0; i < lines.length; i++) {
        let line = lines[i];
        if (line.record['SBQQ__Product__c']) { productIds.push(line.record['SBQQ__Product__c']); }
        if (line.record['Plant__c']) { plants.add(line.record['Plant__c']); }
        if (line.record['SBQQ__ProductCode__c']) { productCodes.add(line.record['SBQQ__ProductCode__c']); }
    }

    return conn.query("SELECT Id, Name, ProductCode, " + Object.keys(objFieldMap.Product2).join(",") + " FROM Product2 WHERE Id IN ('" + productIds.join("','") + "')").then((result) => {
        if (result && result.totalSize > 0) {
            let productIndexMap = {};
            let products = result.records;
            for (let i = 0; i < products.length; i++) {
                let product = products[i];
                for (let field in objFieldMap.Product2) {
                    if (product[field]) {
                        dataSet[field] = (dataSet[field]) ? dataSet[field] : new Set();
                        dataSet[field].add(product[field]);
                    }
                    productIndexMap[product.Id] = i;
                }
            } console.log('dataSet', dataSet);

            let brandFilters = [];
            if (quote.record['Sub_Market__c']) {
                brandFilters.push(objFieldMap.SBQQ__Quote__c.Sub_Market__c + " = '" + quote.record['Sub_Market__c'] + "'");
            }
            if (plants && plants.size > 0) {
                brandFilters.push(objFieldMap.SBQQ__QuoteLine__c.Plant__c + " IN ('" + Array.from(plants).join("','") + "')");
            }
            if (dataSet) {
                for (let productField in dataSet) {
                    brandFilters.push(objFieldMap.Product2[productField] + " IN ('" + Array.from(dataSet[productField]).join("','") + "')");
                }
            } console.log('brandFilters', brandFilters);

            if (brandFilters && brandFilters.length > 0) {
                let fieldsSet = new Set();
                for (let object in objFieldMap) { for (let field in objFieldMap[object]) { fieldsSet.add(objFieldMap[object][field]); } }
                conn.query('SELECT Id, Brand_Name__c, ' + Array.from(fieldsSet).join(',') + ' FROM Brand_Names__c WHERE ' + brandFilters.join(' AND ') + ' ORDER BY ' + Array.from(fieldsSet).join(',')).then((result) => {
                    if (result && result.totalSize > 0) {
                        let brandNames = result.records;
                        console.log('brandNames', brandNames);

                        lines.forEach(line => {
                            console.log('line', line);
                            for (let i = 0; i < brandNames.length; i++) {
                                let brand = brandNames[i];
                                let match = true;
                                console.log('brand', brand);
                                // if (objFieldMap.SBQQ__Quote__c) {
                                //     for (let field in objFieldMap.SBQQ__Quote__c) {
                                //         console.log(quote.record[field], brand[objFieldMap.SBQQ__Quote__c[field]]);
                                //         if (quote.record[field] !== brand[objFieldMap.SBQQ__Quote__c[field]]) {
                                //             match = false; break;
                                //         }
                                //     }
                                //     if (!match) { continue; }
                                // }

                                if (objFieldMap.SBQQ__QuoteLine__c) {
                                    for (let field in objFieldMap.SBQQ__QuoteLine__c) {
                                        console.log(line.record[field], brand[objFieldMap.SBQQ__QuoteLine__c[field]]);
                                        if (line.record[field] !== brand[objFieldMap.SBQQ__QuoteLine__c[field]]) {
                                            match = false; break;
                                        }
                                    }
                                    if (!match) { continue; }
                                }

                                if (objFieldMap.Product2 && productIndexMap[line.record.SBQQ__Product__c]) {
                                    let index = productIndexMap[line.record.SBQQ__Product__c];
                                    for (let field in objFieldMap.Product2) {
                                        console.log(products[index][field], brand[objFieldMap.Product2[field]]);
                                        if (products[index][field] !== brand[objFieldMap.Product2[field]]) {
                                            match = false; break;
                                        }
                                    }
                                    if (!match) { continue; }
                                }
                                console.log(line.record.Brand_Text__c, brand.Brand_Name__c);
                                line.record.Brand_Text__c = brand.Brand_Name__c;
                                break;
                            }
                        });
                    } calculateSalesAndCustomerText(quote, lines, conn, products, productCodes);
                });
            } else {
                calculateSalesAndCustomerText(quote, lines, conn, products, productCodes);
            }
        }
    });
}
function calculateSalesAndCustomerText(quote, lines, conn, products, productCodes) {
    let objFieldMap = {
        Sales_Text__c: { SBQQ__Quote__c: { SBQQ__QuoteLanguage__c: 'Language__c' } },
        Customer_Text__c: {
            SBQQ__Quote__c: { Account_SAP_Id__c: 'Customer_Code__c' },
            SBQQ__QuoteLine__c: { SBQQ__ProductCode__c: 'Name' }
        }
    };

    let descFiltersMap = { Sales_Text__c: [], Customer_Text__c: [] };
    if (quote.record.SBQQ__QuoteLanguage__c) {
        descFiltersMap.Sales_Text__c.push(objFieldMap.Sales_Text__c.SBQQ__Quote__c.SBQQ__QuoteLanguage__c + " = '" + quote.record.SBQQ__QuoteLanguage__c + "'");
    }
    if (quote.record.Account_SAP_Id__c) {
        descFiltersMap.Customer_Text__c.push(objFieldMap.Customer_Text__c.SBQQ__Quote__c.Account_SAP_Id__c + " = '" + quote.record.Account_SAP_Id__c + "'");
    }
    if (productCodes && productCodes.size > 0) {
        descFiltersMap.Customer_Text__c.push(objFieldMap.Customer_Text__c.SBQQ__QuoteLine__c.SBQQ__ProductCode__c + " IN ('" + Array.from(productCodes).join("','") + "')");
    }
    console.log('descFiltersMap', descFiltersMap);
    let descFilters = [];
    for (let key in descFiltersMap) {
        if (descFiltersMap[key] && descFiltersMap[key].length > 0) {
            descFilters.push(descFiltersMap[key].join(' AND '));
        }
    }

    console.log('descFilters', descFilters);
    if (descFilters.length > 0) {
        return conn.query('SELECT Id, Name, Customer_Code__c, Description__c, Language__c FROM Product_Description__c WHERE (' + descFilters.join(') OR (') + ')').then((result) => {
            if (typeof result !== "undefined" && result.totalSize > 0) {
                let descs = result.records;
                console.log('descs', descs);
                lines.forEach(line => {
                    console.log('line', line);
                    for (let i = 0; i < descs.length; i++) {
                        let desc = descs[i];
                        let match = { Sales_Text__c: true, Customer_Text__c: true };
                        console.log('desc', desc);
                        for (let key in objFieldMap) {
                            if (objFieldMap[key].SBQQ__Quote__c) {
                                for (let field in objFieldMap[key].SBQQ__Quote__c) {
                                    console.log(key, match[key], quote.record[field], desc[objFieldMap[key].SBQQ__Quote__c[field]]);
                                    if (quote.record[field] !== desc[objFieldMap[key].SBQQ__Quote__c[field]]) {
                                        match[key] = false; break;
                                    }
                                }
                                if (!match[key]) { continue; }
                            }

                            if (objFieldMap[key].SBQQ__QuoteLine__c) {
                                for (let field in objFieldMap[key].SBQQ__QuoteLine__c) {
                                    console.log(key, match[key], line.record[field], desc[objFieldMap[key].SBQQ__QuoteLine__c[field]]);
                                    if (line.record[field] !== desc[objFieldMap[key].SBQQ__QuoteLine__c[field]]) {
                                        match[key] = false; break;
                                    }
                                }
                                if (!match[key]) { continue; }
                            }

                            line.record[key] = desc.Description__c;
                        }

                        let matchAll = true;
                        for (let key in match) { matchAll = matchAll && match[key]; }
                        if (matchAll) { break; }
                    }
                });
            }
            console.log(lines);
        });
    }
}





/*
export function onBeforeCalculate(quote, lines, conn) {
    console.log(quote); console.log(lines); console.log(conn);
    if (lines.length > 0) { return calculateBrandText(quote, lines, conn); }
    return Promise.resolve();
}
function calculateBrandText(quote, lines, conn) {
    let dataSet = {}; let productIds = [];
    let objFieldMap = {
        SBQQ__Quote__c: { 'Sub_Market__c': 'Market_Segment_Code__c' },
        SBQQ__QuoteLine__c: { 'Plant__c': 'Plant_Code__c' },
        Product2: {
            Composition__c: 'Product_Comp_Code__c',
            Family: 'Product_Family_Code__c',
            Size__c: 'Product_Size_Code__c',
            Product_Type__c: 'Product_Type_Code__c'
        }
    };

    let plants = new Set();
    let productCodes = new Set();
    for (let i = 0; i < lines.length; i++) {
        let line = lines[i];
        if (line.record['SBQQ__Product__c']) {
            productIds.push(line.record['SBQQ__Product__c']);
        }
        if (line.record['Plant__c']) {
            plants.add(line.record['Plant__c']);
        }
        if (line.record['SBQQ__ProductCode__c']) {
            productCodes.add(line.record['SBQQ__ProductCode__c']);
        }
    }

    return conn.query("SELECT Id, Name, ProductCode, " + Object.keys(objFieldMap.Product2).join(",") + " FROM Product2 WHERE Id IN ('" + productIds.join("','") + "')").then((result) => {
        if (result && result.totalSize > 0) {
            let productIndexMap = {};
            let products = result.records;
            for (let i = 0; i < products.length; i++) {
                let product = products[i];
                for (let field in objFieldMap.Product2) {
                    if (product[field]) {
                        dataSet[field] = (dataSet[field]) ? dataSet[field] : new Set();
                        dataSet[field].add(product[field]);
                    }
                    productIndexMap[product.Id] = i;
                }
            } console.log('dataSet', dataSet);

            let brandFilters = [];
            if (quote.record['Sub_Market__c']) {
                brandFilters.push(objFieldMap.SBQQ__Quote__c.Sub_Market__c + " = '" + quote.record['Sub_Market__c'] + "'");
            }
            if (plants && plants.size > 0) {
                brandFilters.push(objFieldMap.SBQQ__QuoteLine__c.Plant__c + " IN ('" + Array.from(plants).join("','") + "')");
            }
            if (dataSet) {
                for (let productField in dataSet) {
                    brandFilters.push(objFieldMap.Product2[productField] + " IN ('" + Array.from(dataSet[productField]).join("','") + "')");
                }
            } console.log('brandFilters', brandFilters);

            if (brandFilters && brandFilters.length > 0) {
                let fieldsSet = new Set();
                for (let object in objFieldMap) { for (let field in objFieldMap[object]) { fieldsSet.add(objFieldMap[object][field]); } }
                conn.query("SELECT Id, Brand_Name__c, " + Array.from(fieldsSet).join(',') + " FROM Brand_Names__c WHERE " + brandFilters.join(' AND ') + ' ORDER BY ' + Array.from(fieldsSet).join(',')).then((result) => {
                    if (result && result.totalSize > 0) {
                        let brandNames = result.records;
                        console.log('brandNames', brandNames);

                        lines.forEach(line => {
                            console.log('line', line);
                            for (let i = 0; i < brandNames.length; i++) {
                                let brand = brandNames[i];
                                let match = true;
                                console.log('brand', brand);
                                if (objFieldMap.SBQQ__Quote__c) {
                                    for (let field in objFieldMap.SBQQ__Quote__c) {
                                        console.log(quote.record[field], brand[objFieldMap.SBQQ__Quote__c[field]]);
                                        if (quote.record[field] !== brand[objFieldMap.SBQQ__Quote__c[field]]) {
                                            match = false; break;
                                        }
                                    }
                                    if (!match) { continue; }
                                }

                                if (objFieldMap.SBQQ__QuoteLine__c) {
                                    for (let field in objFieldMap.SBQQ__QuoteLine__c) {
                                        console.log(line.record[field], brand[objFieldMap.SBQQ__QuoteLine__c[field]]);
                                        if (line.record[field] !== brand[objFieldMap.SBQQ__QuoteLine__c[field]]) {
                                            match = false; break;
                                        }
                                    }
                                    if (!match) { continue; }
                                }

                                if (objFieldMap.Product2 && productIndexMap[line.record.SBQQ__Product__c]) {
                                    let index = productIndexMap[line.record.SBQQ__Product__c];
                                    for (let field in objFieldMap.Product2) {
                                        console.log(products[index][field], brand[objFieldMap.Product2[field]]);
                                        if (products[index][field] !== brand[objFieldMap.Product2[field]]) {
                                            match = false; break;
                                        }
                                    }
                                    if (!match) { continue; }
                                }
                                console.log(line.record.Brand_Text__c, brand.Brand_Name__c);
                                line.record.Brand_Text__c = brand.Brand_Name__c;
                                break;
                            }
                        });
                    } calculateSalesAndCustomerText(quote, lines, conn, products, productCodes);
                });
            } else {
                calculateSalesAndCustomerText(quote, lines, conn, products, productCodes);
            }
        }
    });
}
function calculateSalesAndCustomerText(quote, lines, conn, products, productCodes) {
    let objFieldMap = {
        Sales_Text__c: { SBQQ__Quote__c: { SBQQ__QuoteLanguage__c: 'Language__c' } },
        Customer_Text__c: {
            SBQQ__Quote__c: { Account_SAP_Id__c: 'Customer_Code__c' },
            SBQQ__QuoteLine__c: { SBQQ__ProductCode__c: 'Name' }
        }
    };

    let descFiltersMap = { Sales_Text__c: [], Customer_Text__c: [] };
    if (quote.record.SBQQ__QuoteLanguage__c) {
        descFiltersMap.Sales_Text__c.push(objFieldMap.Sales_Text__c.SBQQ__Quote__c.SBQQ__QuoteLanguage__c + " = '" + quote.record.SBQQ__QuoteLanguage__c + "'");
    }
    if (quote.record.Account_SAP_Id__c) {
        descFiltersMap.Customer_Text__c.push(objFieldMap.Customer_Text__c.SBQQ__Quote__c.Account_SAP_Id__c + " = '" + quote.record.Account_SAP_Id__c + "'");
    }
    if (productCodes && productCodes.size > 0) {
        descFiltersMap.Customer_Text__c.push(objFieldMap.Customer_Text__c.SBQQ__QuoteLine__c.SBQQ__ProductCode__c + " IN ('" + Array.from(productCodes).join("','") + "')");
    }
    console.log('descFiltersMap', descFiltersMap);
    let descFilters = [];
    for (let key in descFiltersMap) {
        if (descFiltersMap[key] && descFiltersMap[key].length > 0) {
            descFilters.push(descFiltersMap[key].join(' AND '));
        }
    }

    console.log('descFilters', descFilters);
    if (descFilters.length > 0) {
        conn.query('SELECT Id, Name, Customer_Code__c, Description__c, Language__c FROM Product_Description__c WHERE (' + descFilters.join(') OR (') + ')').then((result) => {
            if (typeof result !== "undefined" && result.totalSize > 0) {
                let descs = result.records;
                console.log('descs', descs);
                lines.forEach(line => {
                    console.log('line', line);
                    for (let i = 0; i < descs.length; i++) {
                        let desc = descs[i];
                        let match = { Sales_Text__c: true, Customer_Text__c: true };
                        console.log('desc', desc);
                        for (let key in objFieldMap) {
                            if (objFieldMap[key].SBQQ__Quote__c) {
                                for (let field in objFieldMap[key].SBQQ__Quote__c) {
                                    console.log(key, match[key], quote.record[field], desc[objFieldMap[key].SBQQ__Quote__c[field]]);
                                    if (quote.record[field] !== desc[objFieldMap[key].SBQQ__Quote__c[field]]) {
                                        match[key] = false; break;
                                    }
                                }
                                if (!match[key]) { continue; }
                            }

                            if (objFieldMap[key].SBQQ__QuoteLine__c) {
                                for (let field in objFieldMap[key].SBQQ__QuoteLine__c) {
                                    console.log(key, match[key], line.record[field], desc[objFieldMap[key].SBQQ__QuoteLine__c[field]]);
                                    if (line.record[field] !== desc[objFieldMap[key].SBQQ__QuoteLine__c[field]]) {
                                        match[key] = false; break;
                                    }
                                }
                                if (!match[key]) { continue; }
                            }

                            line.record[key] = desc.Description__c;
                        }

                        let matchAll = true;
                        for (let key in match) { matchAll = matchAll && match[key]; }
                        if (matchAll) { break; }
                    }
                });
            }
            console.log(lines);
        });
    }
} */