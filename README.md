# [POC] > Data-Warehouse > WideWorldImporters


# Introduction

In today's fast paced data-driven business landscape, a deep understanding of organization's operations and objectives is the key to unlocking the full potential. That's where a comprehentive data warehousing solution comes into play.

A comprehensive data warehousing solution for the fictional company 'WideWorldImporters'. This solution has been implemented using Microsoft SQL Server Management Studio (SSMS) and SQL Server Reporting Services (SSRS).

In this project, I designed a POC [Proof of Concept] data warehousing solution. The project also highlights a robust ETL (Extract, Transform, Load) process that effectively cleanses and transforms the raw data before loading it into the warehouse.

To provide insights into the data, several dashboards and reports were created using SSRS that enable stakeholders to track key performance metrics, monitor trends, and identify opportunities for improvement. These reports provide real-time insights that help drive strategic decision-making across the organization.

Overall, this data warehousing solution is a comprehensive, end-to-end solution that provides 'WideWorldImporters' with the tools and insights needed to thrive in a highly competitive marketplace. I am excited to share this project with you, and I hope that it inspires you to explore the vast possibilities of data warehousing using SSMS and SSRS.

# Data Source
Wide World Importers (WWI) is a wholesale novelty goods importer and distributor operating from the San Francisco bay area.

# Business Requirements
To provide business a hollistic understanding of their operations and objectives through BI solutions ulilizing data
To gain immersive understanding of operational processes, business dynamics related to customer, supplier, inventory, products and sales
Establish a KPI (Key Performance Indicator) measurement strategy to keep a check on current performance and ensure growth trajectory staying at the right path
Keep the data structured, organized so that it can be used to compliment future BI solutions
Keep in mind future needs, anticipate future requirements and challenges related to querying data
Ensure an effective data strategy is in place resulting in long term success and provides competitive edge to business through data


#Designed Schema for the Warehouse

#Dimensions
 1. Supplier_Dim
 3. Warehouse_Dim
 4. Product_Dim
 5. ProductCategory_Dim


#Fact Tables
1. EmployeeCustomer_Fact
2. Warehouse_Fact


# SQL Implementation
SQL Implementation was accomplished with the use of Microsoft SQL Server Management Studio.
SQL implementation is enabling structured data in a way that reflects unique business logic and requirements, facilitating seamless integration and transformation of disparate data sources into a unified, reliable, and trustworthy repository.


# Data insights
The warehousing solution is fueling business growth by continously providing data and insights to unlock the full potential of business.
Now, the business knows where it was, where it is and where it is headed.

1.	Suppliers:
  •	Supplier Performance: Evaluate supplier performance metrics such as on-time deliveries, quality issues, lead times, and pricing to identify top-performing suppliers and areas for improvement.
  •	Supplier Relationship Management: Analyze historical supplier data to negotiate better contracts, optimize supplier selection, and enhance collaboration with key suppliers.
  •	Supplier Risk Assessment: Monitor supplier risk factors such as financial stability, delivery delays, or disruptions to proactively mitigate potential risks.
2.	Customers:
  •	Customer Segmentation: Segment customers based on various attributes such as demographics, purchase history, and behavior to tailor marketing campaigns, personalize customer experiences, and maximize customer lifetime value.
  •	Customer Churn Analysis: Identify factors leading to customer churn, such as dissatisfaction or competitive offers, and implement retention strategies to minimize customer attrition.
  •	Cross-Selling and Upselling Opportunities: Analyze customer purchase patterns and preferences to identify cross-selling and upselling opportunities, enabling targeted sales and marketing strategies.
3.	Inventory:
  •	Demand Forecasting: Analyze historical sales data and market trends to forecast future demand accurately, optimizing inventory levels and reducing stockouts or excess inventory.
  •	Inventory Turnover and Aging: Monitor inventory turnover rates and identify slow-moving or obsolete stock to optimize inventory management and reduce carrying costs.
  •	Supply Chain Optimization: Analyze inventory data in conjunction with supplier and customer information to identify bottlenecks, streamline supply chain processes, and improve overall efficiency.
4.	Sales:
  •	Sales Performance Analysis: Analyze sales data by product, region, channel, or salesperson to identify top-performing areas, trends, and opportunities for sales growth.
  •	Pricing Analysis: Evaluate pricing strategies, discounts, and promotions to identify optimal pricing points, improve profitability, and understand price elasticity.
  •	Sales Forecasting: Use historical sales data and market factors to forecast future sales, enabling effective resource allocation and strategic planning.
5.	Products:
  •	Product Performance Analysis: Evaluate sales, profitability, and customer feedback for different products to identify high-performing products, understand market demand, and make informed product development decisions.
  •	Product Lifecycle Management: Track product lifecycles, monitor sales patterns, and identify opportunities for product enhancements, replacements, or retirements.
  •	Competitive Analysis: Compare product performance against competitors, analyze market share, and identify areas for differentiation or competitive advantage.


# Tableau 
The tableaau dashboard with its captivating visualizations and interactivity, uncovers a compelling story of Products, Suppliers, Categories, Employees, Customers, 
Transactions, and Sales.

The current tableau dashboard entails the following aspects through different visualizations
- Bubble chart displaying product category and the average price
- Identify top suppliers by the purchase amount
- Showcase top sales representatives by amount of sales generated
- Top customers by purchase amount
- Volume of transactions and sales amount
- Sales by different product category


# SSRS Reports
4 BI reports were created using SSRS.
Reports were targeted to provide insights to stakeholders such as terriroty planners, VPs, Sales Managers, etc.
Another goal of BI reporting was to have an effective way to get new orders, a product catalogue report was developed that lists down all the order related information such as Product name, weight, Minimum order quanity, Price, etc.





