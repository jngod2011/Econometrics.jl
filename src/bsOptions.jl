############
## d1, d2 ##
############

function bsDs(sigma::Float64, S::Float64, K::Int, r::Float64, T::Float64)
    d1 = log(S/(K*exp(-r*T)))/(sigma*sqrt(T)) + 0.5*sigma*sqrt(T)
    d2 = d1 - sigma*sqrt(T)
    
    return (d1, d2)
end

###############
## BS Prices ##
###############

function bsCall(sigma::Float64, S::Float64, K::Int, r::Float64, T::Float64)
    d1, d2 = bsDs(sigma, S, K, r, T)
    
    return S*cdf(Normal(), d1) - K*exp(-r*T)*cdf(Normal(), d2)
end

function bsPut(sigma::Float64, S::Float64, K::Int, r::Float64, T::Float64)
    d1, d2 = bsDs(sigma, S, K, r, T)
    
    return K*exp(-r*T)*cdf(Normal(), -d2) - S*cdf(Normal(), -d1)
end

###########
## Delta ##
###########

function bsDeltaCall(sigma::Float64, S::Float64, K::Int, r::Float64, T::Float64)
    d1, d2 = bsDs(sigma, S, K, r, T)
    return cdf(Normal(), d1)
end

function bsDeltaPut(sigma::Float64, S::Float64, K::Int, r::Float64, T::Float64)
    d1, d2 = bsDs(sigma, S, K, r, T)
    return -cdf(Normal(), -d1)
end

###########
## Gamma ##
###########

function bsGamma(sigma::Float64, S::Float64, K::Int, r::Float64, T::Float64)
    d1, d2 = bsDs(sigma, S, K, r, T)
    return pdf(Normal(), d1)/(S*sigma*sqrt(T))
end

##########
## Vega ##
##########

function bsVega(sigma::Float64, S::Float64, K::Int, r::Float64, T::Float64)
    d1, d2 = bsDs(sigma, S, K, r, T)
    return S*pdf(Normal(), d1)*sqrt(T)
end

###########
## Theta ##
###########

function bsThetaCall(sigma::Float64, S::Float64, K::Int, r::Float64, T::Float64)
    d1, d2 = bsDs(sigma, S, K, r, T)
    return -r*exp(-r*T)*K*cdf(Normal(), d2) - sigma*S*pdf(Normal(), d1)/(2*sqrt(T))
end

function bsThetaPut(sigma::Float64, S::Float64, K::Int, r::Float64, T::Float64)
    d1, d2 = bsDs(sigma, S, K, r, T)
    return r*exp(-r*T)*K*cdf(Normal(), -d2) - sigma*S*pdf(Normal(), d1)/(2*sqrt(T))
end

#########
## Rho ##
#########

function bsRhoCall(sigma::Float64, S::Float64, K::Int, r::Float64, T::Float64)
    d1, d2 = bsDs(sigma, S, K, r, T)
    return exp(-r*T)*K*T*cdf(Normal(), d2)
end

function bsRhoPut(sigma::Float64, S::Float64, K::Int, r::Float64, T::Float64)
    d1, d2 = bsDs(sigma, S, K, r, T)
    return -exp(-r*T)*K*T*cdf(Normal(), -d2)
end

########################
## Implied volatility ##
########################

function implVolaCall(sigma0::Float64, P::Float64, S::Float64, K::Int, r::Float64, T::Float64, prec::Float64)
    # define maximum interation size
    maxIter = 1000
    
    # calculate deviation
    d1, d2 = bsDs(sigma0, S, K, r, T)
    currDelta = cdf(Normal(), d1)
    currPrice = S*currDelta - K*exp(-r*T)*cdf(Normal(), d2)
    dev = P - currPrice
    
    iterCounter = 0
    while (dev > prec) && (iterCounter < maxIter)
        # Newton Raphson
        sigma0 = sigma0 - currPrice/currDelta
        
        # new d1, d2, delta, price and deviation
        d1, d2 = bsDs(sigma0, S, K, r, T)
        currDelta = cdf(Normal(), d1)
        currPrice = S*currDelta - K*exp(-r*T)*cdf(Normal(), d2)
        dev = P - currPrice
        iterCounter += 1
    end
    return (sigma0, dev, iterCounter)
end
