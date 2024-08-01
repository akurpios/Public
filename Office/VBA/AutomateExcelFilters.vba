function main(workbook: ExcelScript.Workbook) {
	let results = workbook.getTable("Results16");
	results.getColumnByName("Sender or Created by").getFilter().applyCustomFilter("<>*@polaroid.com>");
	results.getColumnByName("Recipients in To line").getFilter().applyCustomFilter("=*steve*");
	results.getColumnByName("Received or Created").getFilter().applyCustomFilter(">27/05/2024", "<29/05/2024", ExcelScript.FilterOperator.and);
	results.getSort().apply([{ key: 25, ascending: true }]);
}
