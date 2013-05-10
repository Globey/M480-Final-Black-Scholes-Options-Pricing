from scipy import stats
from scipy.stats import norm
from math import log,sqrt,pow,exp

#Later add functionality to handle puts, default will be calls.
def black_scholes(time_to_maturity,spot_price,strike_price,risk_free_rate,sigma):
	''' time_to_maturity: is the option's time to maturity
		spot_price: is 
		...
	'''
	
	#First we calculate d1, d1=d11*d12, d12=d121+d122*d123
	d11 = 1/(sigma*sqrt(time_to_maturity))
	
	d121 = log(spot_price/strike_price)
	d122 = risk_free_rate + pow(sigma,2)/2
	d123 = time_to_maturity
	d12 = d121+d122*d123
	
	d1 = d11*d12
	d2 = d1 - sigma*sqrt(time_to_maturity)
	
	call_value = norm.cdf(d1)*spot_price - norm.cdf(d2)*strike_price*exp(-1*risk_free_rate*time_to_maturity)
	
	return call_value
	