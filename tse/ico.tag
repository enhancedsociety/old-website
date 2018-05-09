<ico class="col-lg-4 col-md-6 mb-4">
    <div class="card">
        <div class="card-body rounded text-center">

            <br />

            <div class="avatar mx-auto">
                <img style="width:30%;" src="{opts.logo}" class="rounded-circle"></img>
            </div>
            <h2 class="card-title pt-2 white-text">{opts.name}</h2>
            <p class="card-text white-text">{opts.description}</p>

            <div class="steps-form">
                <div class="steps-row setup-panel text-white">
                    <div class="steps-step">
                        <a href="#step-1" type="button" class="btn btn-white btn-circle disabled"></a>
                        <h6>
                            <small>Kickoff</small>
                        </h6>
                    </div>
                    <div class="steps-step">
                        <a href="#step-2" type="button" class="btn btn-white btn-circle disabled"></a>
                        <h6>
                            <small>Private sale</small>
                        </h6>
                    </div>
                    <div class="steps-step">
                        <a href="#step-3" type="button" class="btn btn-white btn-circle disabled"></a>
                        <h6>
                            <small>Pre sale</small>
                        </h6>
                    </div>
                    <div class="steps-step">
                        <a href="#step-4" type="button" class="btn btn-white btn-circle disabled"></a>
                        <h6>
                            <small>Public sale</small>
                        </h6>
                    </div>
                    <div class="steps-step">
                        <a href="#step-5" type="button" class="btn btn-white btn-circle disabled"></a>
                        <h6>
                            <small>Token release</small>
                        </h6>
                    </div>
                </div>
            </div>

        </div>
        <div class="card-body text-center white">

            <canvas id="radarChart"></canvas>

            <br />

            <a href="#!" class="btn btn-info btn-sm">Learn</a>
            <a href="#!" class="btn btn-info btn-sm">Use</a>
            <a href="#!" class="btn btn-info btn-sm">Invest</a>


        </div>
        <!--card body-->
    </div>
    <!--card-->

    <style>
    </style>

    <script>
        this.on('mount', () => {
            // Add color scheme
            this.root.querySelector(`.card-body`).classList.add(...opts.colorScheme);
            
            // Style the current step properly
            this.root.querySelector(`a[href="#step-${opts.step}"]`).classList.remove('disabled');
            
            // Build chart
            const ctxR = this.root.querySelector("canvas#radarChart").getContext('2d');
            const myRadarChart = new Chart(ctxR, {
                type: 'radar',
                data: {
                    labels: ["Easy", "Useful", "Secure", "Legal", "Open"],
                    datasets: [
                        {
                            label: "Quality evaluation",
                            backgroundColor: "#01bcd550",
                            pointBackgroundColor: "#01bcd5f0",
                            lineTension: 0.05,
                            borderWidth: 1,
                            data: [opts.scoreEasy, opts.scoreUseful, opts.scoreSecure, opts.scoreLegal, opts.scoreOpen].map(x => parseInt(x, 10))
                        }
                    ]
                },
                options: {
                    responsive: true,
                    legend: {
                        display: false
                    },
                    scale: {
                        ticks: {
                            display: false,
                            min: 0,
                            max: 5
                        }
                    }
                }
            });
        })
    </script>

</ico>