"""
 Tools for working with financial options
 
 AUTHORS:
 - Brian Manion, 2013: initial version
"""

cdef extern from "math.h":
    double erf(double)
    double exp(double)
    double log(double)
    double sqrt(double)

def black_scholes(double spot_price, double strike_price, double time_to_maturity, double risk_free_rate, double vol, opt_type):
    r""" 
    Calculates call/put price of Eurpoean style options using Black-Scholes formula.
    
    INPUT:
    
    - `spot_price` -- The current underlying asset price
    - `strike_price` -- The strike of the option
    - `time_to_maturity` --  The # of years until expiration
    - `risk_free_rate` -- The risk-free interest-rate 
    - `vol` -- The volatility
    - `opt_type` -- string; The type of option, either 'put' for put option or 'call' for call option
    
    OUTPUT:
        The price of an option with the given parameters.
        
    Examples::
    
        sage: finance.black_scholes(42, 40, 0.5, 0.1, 0.2, 'call')
        4.759422392871532
        sage: finance.black_scholes(42, 40, 0.5, 0.1, 0.2, 'put')
        0.8085993729000958
        sage: finance.black_scholes(100, 95, 0.25, 0.1, 0.5, 'call')
        13.695272738608132
        sage: finance.black_scholes(100, 95, 0.25, 0.1, 0.5, 'put')
        6.349714381299734
        sage: finance.black_scholes(527.07, 520, 0.424563772, 0.0236734,0.15297,'whichever makes me more money')
        Traceback (most recent call last):
        ...
        ValueError: 'whichever makes me more money' is not a valid string  
    """
    #First we calculate d1, d1=d11*d12, d12=d121+d122*d123
    cdef double d11 = 1/(vol*sqrt(time_to_maturity))
    
    cdef double d121 = log(spot_price/strike_price)
    cdef double d122 = risk_free_rate + pow(vol,2)/2
    cdef double d123 = time_to_maturity
    cdef double d12 = d121+d122*d123
    
    cdef double d1 = d11*d12
    cdef double d2 = d1 - vol*sqrt(time_to_maturity)
    
    cdef double call_value = _std_norm_cdf(d1)*spot_price - _std_norm_cdf(d2)*strike_price*exp(-1*risk_free_rate*time_to_maturity)
    cdef double put_value = _std_norm_cdf(-1*d2)*strike_price*exp(-1*risk_free_rate*time_to_maturity) - _std_norm_cdf(-1*d1)*spot_price
    
    if opt_type == 'call':
        return call_value
    elif opt_type == 'put':
        return put_value
    else:
        raise ValueError("'%s' is not a valid string" % opt_type)
        
def _std_norm_cdf(double x):
    r"""
    Standard normal cumulative distribution function; Used internally. 
    
    INPUT:
    
    - `x` -- The upper limit of integration for the standard normal cdf
    
    OUTPUT:
        The probability that a random variable X, which is standard normally distributed, takes on a value 
        less than or equal to x.
        
    Examples::
        sage: from sage.finance.option import _std_norm_cdf
        sage: _std_norm_cdf(0)
        0.5
        sage: x = _std_norm_cdf(1.96); x
        0.9750021048517795
        sage: y = _std_norm_cdf(-1.96); y
        0.02499789514822044
        sage: x + y
        1.0
    """
    cdef double e1 = x/sqrt(2)
    cdef double prob = 0.5*(1+erf(e1))
    return prob