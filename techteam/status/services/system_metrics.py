import subprocess

# gets the amount of free memory of system
def system_metrics():
    with open('./status/services/system_metrics.sh', 'rb') as file:
        script = file.read()
        out = subprocess.check_output(script, shell=True).decode('utf-8').split(':') # splitting by delimeter to get all metrics
        out = [o.strip() for o in out]

        metrics = {
            'load': out[0],
            'mem': out[1],
            'disk': out[2],
            'kern': out[3],
            'packs': [p.strip() for p in out[4].split('\n')] # splitting packages which are seperated by a newline
        }

        return metrics
