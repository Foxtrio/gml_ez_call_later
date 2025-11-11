// By FrozenAra
/**
 * Creates a simple wrapper around call_later with easier control and debugging.
 * @param {function} _callback  Function to call when the timer expires.
 * @param {real} _time_period  Delay before execution (depends on unit).
 * @param {real} _unit  Unit for timing (seconds or frames).
 * @param {bool} _loop  Whether the callback should repeat.
 */
function ez_call_later(_callback, _time_period, _unit=time_source_units_seconds, _loop=false) constructor
{
    handler = undefined;
    time_period = _time_period;
    loop = _loop;
    unit = _unit;
    callback = _callback;
    _is_running = false;
    
    parameters = undefined;
    
    /**
     * Sets the parameters for the callback function.
     * @param {array} _params - The parameters to be included in the callback function.
     */
    static set_parameters = function(_params){
        parameters = _params;
        
        return self;
    }
    
    
    /**
     * Sets the callback function. This will immediately take effect for the next call
     * @param {function} _callback - The function to be executed when triggered.
     */
    static set_callback = function(_callback){
        callback = _callback;
        
        return self;
    }
    
    /**
     * Sets the delay period before the callback executes.
     * @param {number} _time_period - Delay value.
     */
    static set_time_period = function(_time_period){
        time_period = _time_period;
        
        return self;
    }
    
    /**
     * Sets the unit of measurement for the timer.
     * @param {number} _unit - Must be either time_source_units_frames or time_source_units_seconds.
     */
    static set_unit = function(_unit){
        if(_unit != time_source_units_frames && _unit != time_source_units_seconds)
        {
            show_debug_message("[EZ Call Later] Invalid time source unit");
            return;
        }
        unit = _unit;
        
        return self;
    }
    
    /**
     * Sets whether the callback should repeat.
     * @param {bool} _repeat - True if repeating, false if one-shot.
     */
    static set_repeat = function(_repeat){
        loop = _repeat;
        
        return self;
    }
    
    /**
     * Checks if the timer is currently running.
     * @returns {bool} True if running, false otherwise.
     */
    static is_running = function(){return _is_running;}
    
    /**
     * Starts the timer with the given configuration.
     * Cancels any existing timer before starting a new one.
     */
    static start = function(){
        if(time_period <= -1 || is_undefined(callback))
        {
            show_debug_message($"[EZ Call Later] Can't start call later timer. Missing data. Callback:{callback}, Period: {time_period}");
            return;
        }
        if(!is_undefined(handler))
        {
            call_cancel(handler);
        }
        handler = call_later(time_period, unit, _internal_callback, loop);
        _is_running = true;
        
        return self;
    }
    
    /**
     * Stops the current timer, if active.
     */
    static stop = function(){
        if(is_undefined(handler))
        {
            return;
        }
        call_cancel(handler);
        handler = undefined;
        _is_running = false;
        
        return self;
    }
    /**
     * Runs callback once, then starts the timer.
     */
    static run_now_and_schedule = function()
    {
        _internal_callback();
        start();
        
        return self;
    }
    
    /** Restarts call later
     * @param {real} _time_period Optional parameter to restart with a different timer
     */
    static restart = function(_time_period=-1)
    {
        if(_time_period > -1)
        {
            time_period = _time_period;
        }
        stop();
        start();
        
        return self;
    }
    
    /**
     * Internal wrapper that executes the callback and handles errors.
     */
    _internal_callback = function(){
        if(is_undefined(callback))
        {
            show_debug_message("[EZ Call Later] Can't call undefined function");
            return
        }
        try 
        {
            if (parameters == undefined) 
            {
                callback();
            } else 
            {
                callback(parameters);
            }
            
            if(!loop)
            {
                stop();
            }
        }
        catch (ex)  
        {
            show_debug_message("[EZ Call Later] Failed to call callback function:");
            show_debug_message(ex);
            if(!loop)
            {
                show_debug_message("[EZ Call Later] Stopping oneshot after error");
                stop();
            }
        }
    }
}
