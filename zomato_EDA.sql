#1. What is the total amount of each customer spend on zomato ?
select a.userid, sum(b.price) as total_amount from sales a inner join product b on 
a.product_id = b.product_id 
group by a.userid;

#2 How many days each customer visited zomato?
select userid, count(distinct created_date) as distinct_day from sales 
group by 1;


#3 What was the first product purchsed by each customer?
select * from (
select *, rank() over(partition by userid order by created_date) rnk
 from sales) t where t.rnk = 1;
 
 
 #4. What is the most purchased item on the menu and how many times was it purchased by all customers?
 select userid, count(product_id) cnt from sales where product_id =
 (select  product_id from sales 
 group by product_id
 order by count(product_id) desc limit 1) 
 group by userid;
 
 #5. Which item was the most popular for each customer?
 select * from (
 select *, rank() over(partition by userid order by cnt desc) rnk from (
 select userid, product_id, count(product_id) cnt from sales
 group by userid, product_id) a 
 ) b where rnk = 1;
 
 #6. Which item was purchased first by the customer after they became a member?
 select * from 
 (select temp.*, rank() over(partition by userid order by created_date) rnk from 
 (select s.userid, s.created_date, s.product_id, gp.gold_signup_date from
 sales s inner join goldusers_signup gp on 
 s.userid = gp.userid and 
 created_date >= gold_signup_date) temp)
 temp1 where rnk = 1;
 
 
 #7. Which item was purchased just before the customer beacame a member?
 select * from 
 (select temp.*, rank() over(partition by userid order by created_date desc) rnk from 
 (select s.userid, s.created_date, s.product_id, gp.gold_signup_date from
 sales s inner join goldusers_signup gp on 
 s.userid = gp.userid and 
 created_date <= gold_signup_date) temp)
 temp1 where rnk = 1;
 
 
 #8. What is the total orders and amount spent for each member before they became a member?
 select userid,count(created_date) order_purchase, sum(price) total_amt_spent from
 (select temp.*, p.price from 
 (select s.userid, s.created_date, s.product_id, gp.gold_signup_date from
 sales s inner join goldusers_signup gp on 
 s.userid = gp.userid and 
 created_date <= gold_signup_date) temp
 inner join product p on 
 temp.product_id=p.product_id) temp1
 group by userid;
 
 #9. If buying each product generates points for i.e 5 RS = 2 Zomato points and each product has different purchasing points 
 # for i.e. for p1 5 rs = 1 Zomato point, for p2 10 rs = % Zomato points and for p3 5 RS = 1 zomato point. Calculate points collected by each 
 #customer and for which product most points have been given till now.
 select userid,sum(total_points) total_points_earned from
 (select e.*, round(amt/Points,0) total_points from
 (select d.*, 
 case 
	when product_id = 1 then 5
	when product_id = 2 then 2
	when product_id=3 then 5
	else 0
 end as 'Points' from
 (select c.userid, c.product_id, sum(price) amt from 
 (select a.*,b.price from sales a inner join product b on a.product_id = 
 b.product_id) c group by userid, product_id) d) e) f group by userid;
 select *, rank() over(order by total_points_earned desc) from 
 (select product_id,sum(total_points) total_points_earned from
 (select e.*, round(amt/Points,0) total_points from
 (select d.*, 
 case 
	when product_id = 1 then 5
	when product_id = 2 then 2
	when product_id=3 then 5
	else 0
 end as 'Points' from
 (select c.userid, c.product_id, sum(price) amt from 
 (select a.*,b.price from sales a inner join product b on a.product_id = 
 b.product_id) c group by userid, product_id) d) e) f group by product_id) g;
 
 
 
 #10. In the first one year after a customer joins the gold program (including their joining date) 
 #irrespective of what the customer has purchased they earn 5 zomato points for every 10 rs spent who earned more 1 or 3 
 #and what was their points earning in their first year? 
select c.*,d.price*0.5 total_points_earned from
( select s.userid, s.created_date, s.product_id, gp.gold_signup_date from
 sales s inner join goldusers_signup gp on 
 s.userid = gp.userid and 
 created_date >= gold_signup_date 
 and created_date<=date_add(gold_signup_date, interval 1 year))
 c inner join product d on c.product_id = d.product_id;
 
 
 #11. Rank all the transaction of the customer.
 select *, rank() over(partition by userid order by created_date ) from sales;
 
 
 #12. Rank all the transaction for each member whenever they are a zomato
 #gold member for every non-gold member transaction mark as na.
 
 select t1.*, case when rnk=0 then 'NA' else rnk end as rnkk from(
 select t.*, case when gold_signup_date is null
 then 0 else rank() 
 over(partition by userid order by gold_signup_date desc) 
 end as rnk from
 (select s.userid, s.created_date, s.product_id, gp.gold_signup_date from
 sales s left join goldusers_signup gp on 
 s.userid = gp.userid and 
 created_date >= gold_signup_date) t) t1;