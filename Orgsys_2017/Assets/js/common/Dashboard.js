var DashboardViewModel = new function () {
    var thisViewModel = this;
    // page-9
    this.getChartData = function () {
        var ctx = document.getElementById("myChart").getContext('2d');
        var myChart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: ["Red", "Blue", "Yellow", "Green", "Purple", "Orange"],
                datasets: [{
                    label: '# of Votes',
                    data: [12, 19, 3, 5, 2, 3],
                    backgroundColor: [
                        'rgba(255, 99, 132, 0.2)',
                        'rgba(54, 162, 235, 0.2)',
                        'rgba(255, 206, 86, 0.2)',
                        'rgba(75, 192, 192, 0.2)',
                        'rgba(153, 102, 255, 0.2)',
                        'rgba(255, 159, 64, 0.2)'
                    ],
                    borderColor: [
                        'rgba(255,99,132,1)',
                        'rgba(54, 162, 235, 1)',
                        'rgba(255, 206, 86, 1)',
                        'rgba(75, 192, 192, 1)',
                        'rgba(153, 102, 255, 1)',
                        'rgba(255, 159, 64, 1)'
                    ],
                    borderWidth: 1
                }]
            },
            options: {
                scales: {
                    yAxes: [{
                        ticks: {
                            beginAtZero: true
                        }
                    }]
                }
            }
        });
    };
    // page-12
    this.getGenderAgeData = function () {      
        var ctx = document.getElementById("genderAge").getContext('2d');
        var myChart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: ["Red", "Blue", "Yellow", "Green", "Purple", "Orange"],
                datasets: [{
                    label: '# of Votes',
                    data: [12, 19, 3, 5, 2, 3],
                    backgroundColor: [
                        'rgba(255, 99, 132, 0.2)',
                        'rgba(54, 162, 235, 0.2)',
                        'rgba(255, 206, 86, 0.2)',
                        'rgba(75, 192, 192, 0.2)',
                        'rgba(153, 102, 255, 0.2)',
                        'rgba(255, 159, 64, 0.2)'
                    ],
                    borderColor: [
                        'rgba(255,99,132,1)',
                        'rgba(54, 162, 235, 1)',
                        'rgba(255, 206, 86, 1)',
                        'rgba(75, 192, 192, 1)',
                        'rgba(153, 102, 255, 1)',
                        'rgba(255, 159, 64, 1)'
                    ],
                    borderWidth: 1
                }]
            },
            options: {
                scales: {
                    yAxes: [{
                        ticks: {
                            beginAtZero: true
                        }
                    }]
                }
            }
        });
    };
    //page-19
    this.getSeniorityData = function () {
        var ctx = document.getElementById("Seniority").getContext('2d');
        var myChart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: ["Red", "Blue", "Yellow", "Green", "Purple", "Orange"],
                datasets: [{
                    label: '# of Votes',
                    data: [12, 19, 3, 5, 2, 3],
                    backgroundColor: [
                        'rgba(255, 99, 132, 0.2)',
                        'rgba(54, 162, 235, 0.2)',
                        'rgba(255, 206, 86, 0.2)',
                        'rgba(75, 192, 192, 0.2)',
                        'rgba(153, 102, 255, 0.2)',
                        'rgba(255, 159, 64, 0.2)'
                    ],
                    borderColor: [
                        'rgba(255,99,132,1)',
                        'rgba(54, 162, 235, 1)',
                        'rgba(255, 206, 86, 1)',
                        'rgba(75, 192, 192, 1)',
                        'rgba(153, 102, 255, 1)',
                        'rgba(255, 159, 64, 1)'
                    ],
                    borderWidth: 1
                }]
            },
            options: {
                scales: {
                    yAxes: [{
                        ticks: {
                            beginAtZero: true
                        }
                    }]
                }
            }
        });
    };
    //page-24
    this.getLagTimeAPSData = function () {
        var ctx = document.getElementById("lagTimeAPS").getContext('2d');
        var myChart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: ["Red", "Blue", "Yellow", "Green", "Purple", "Orange"],
                datasets: [{
                    label: '# of Votes',
                    data: [12, 19, 3, 5, 2, 3],
                    backgroundColor: [
                        'rgba(255, 99, 132, 0.2)',
                        'rgba(54, 162, 235, 0.2)',
                        'rgba(255, 206, 86, 0.2)',
                        'rgba(75, 192, 192, 0.2)',
                        'rgba(153, 102, 255, 0.2)',
                        'rgba(255, 159, 64, 0.2)'
                    ],
                    borderColor: [
                        'rgba(255,99,132,1)',
                        'rgba(54, 162, 235, 1)',
                        'rgba(255, 206, 86, 1)',
                        'rgba(75, 192, 192, 1)',
                        'rgba(153, 102, 255, 1)',
                        'rgba(255, 159, 64, 1)'
                    ],
                    borderWidth: 1
                }]
            },
            options: {
                scales: {
                    yAxes: [{
                        ticks: {
                            beginAtZero: true
                        }
                    }]
                }
            }
        });
    };
    //page-23
    this.getLagTimeReferralData = function () {
        var ctx = document.getElementById("lagTimeReferral").getContext('2d');
        var myChart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: ["Red", "Blue", "Yellow", "Green", "Purple", "Orange"],
                datasets: [{
                    label: '# of Votes',
                    data: [12, 19, 3, 5, 2, 3],
                    backgroundColor: [
                        'rgba(255, 99, 132, 0.2)',
                        'rgba(54, 162, 235, 0.2)',
                        'rgba(255, 206, 86, 0.2)',
                        'rgba(75, 192, 192, 0.2)',
                        'rgba(153, 102, 255, 0.2)',
                        'rgba(255, 159, 64, 0.2)'
                    ],
                    borderColor: [
                        'rgba(255,99,132,1)',
                        'rgba(54, 162, 235, 1)',
                        'rgba(255, 206, 86, 1)',
                        'rgba(75, 192, 192, 1)',
                        'rgba(153, 102, 255, 1)',
                        'rgba(255, 159, 64, 1)'
                    ],
                    borderWidth: 1
                }]
            },
            options: {
                scales: {
                    yAxes: [{
                        ticks: {
                            beginAtZero: true
                        }
                    }]
                }
            }
        });
    };
//page-15 pie
    this.getMedicalConditionData = function () {
        var ctx = document.getElementById("medicalCondition").getContext('2d');
        var myChart = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: [
                    'Red',
                    'Yellow',
                    'Blue'
                ],
                datasets: [{
                    label: '# of Votes',
                    data: [20, 20, 30],
                    backgroundColor: ['#5cb85c', '#D74B4B', '#6685a4'],

                    hoverBackgroundColor: ['#5cb85c', '#D74B4B', '#6685a4'],                   
                 borderWidth: 1
                }]
            },
        });
    };
    //page-17 pie
    this.getMentalHealthClaimByDiagnosisData = function () {
        var ctx = document.getElementById("mentalHealthClaimByDiagnosis").getContext('2d');
        var myChart = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: [
                    'Red',
                    'Yellow',
                    'Blue'
                ],
                datasets: [{
                    label: '# of Votes',
                    data: [20, 20, 30],
                    backgroundColor: ['#5cb85c', '#D74B4B', '#6685a4'],

                    hoverBackgroundColor: ['#5cb85c', '#D74B4B', '#6685a4'],
                    borderWidth: 1
                }]
            },
        });
    };
    //page-18 pie
    this.getMusculoskeletalClaimsByDiagnosisData = function () {
        var ctx = document.getElementById("musculoskeletalClaimsByDiagnosis").getContext('2d');
        var myChart = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: [
                    'Red',
                    'Yellow',
                    'Blue'
                ],
                datasets: [{
                    label: '# of Votes',
                    data: [20, 20, 30],
                    backgroundColor: ['#5cb85c', '#D74B4B', '#6685a4'],

                    hoverBackgroundColor: ['#5cb85c', '#D74B4B', '#6685a4'],
                    borderWidth: 1
                }]
            },
        });
    };
    //page-20 pie
    this.getClosureReasonsData = function () {
        var ctx = document.getElementById("closureReasons").getContext('2d');
        var myChart = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: [
                    'Red',
                    'Yellow',
                    'Blue'
                ],
                datasets: [{
                    label: '# of Votes',
                    data: [20, 20, 30],
                    backgroundColor: ['#5cb85c', '#D74B4B', '#6685a4'],

                    hoverBackgroundColor: ['#5cb85c', '#D74B4B', '#6685a4'],
                    borderWidth: 1
                }]
            },
        });
    };
    //page-22 line
    this.getClosedClaimsData = function () {
        var ctx = document.getElementById("closedClaims")   ;
        let chart = new Chart(ctx, {
            type: 'line',
            data: {
                datasets: [{
                    data: [10, 20, 30, 40, 50, 60]
                }],
                labels: ['January', 'February', 'March', 'April', 'May', 'June'],
            },
            options: {
                scales: {
                    xAxes: [{
                        ticks: {
                            min: 'March'
                        }
                    }]
                }
            }
        });
    };
    // for initializingdashboard 
    this.InitializeView = function () {
        thisViewModel.getChartData();
        thisViewModel.getGenderAgeData();
        thisViewModel.getSeniorityData();
        thisViewModel.getLagTimeAPSData();
        thisViewModel.getLagTimeReferralData();
        thisViewModel.getMedicalConditionData();
        thisViewModel.getMentalHealthClaimByDiagnosisData();
        thisViewModel.getMusculoskeletalClaimsByDiagnosisData();
        thisViewModel.getClosureReasonsData();
        thisViewModel.getClosedClaimsData();

    };
    // filter dashboard according to to from ad devision 
  
};