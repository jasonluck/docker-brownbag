

function getGuestRegistry() {
    $.ajax({
        url: "/services/guest",
        type: "GET",
        contentType: 'application/json; charset=utf-8',
        success: function (data) {
            var tableBody = $("#registry").find('tbody');
            //Clear table data
            tableBody.empty();

            //Add rows to table
            for (var i = 0; i < data.guest.length; i++) {
                var guest = data.guest[i];
                tableBody
                    .append($('<tr>')
                        .append($('<td>')
                            .text(guest.time)
                        )
                        .append($('<td>')
                            .text(guest.firstname)
                        )
                        .append($('<td>')
                            .text(guest.lastname)
                        )
                    )
            }
        },
        error: function (jqXHR, textStatus, errorThrown) {
        },
    });
}

function addGuest(data) {
    $.ajax({
        url: "services/guest",
        type: "POST",
        contentType: 'application/json; charset=utf-8',
        data: JSON.stringify(data),
        success: function () {
            $("#sign-form :input").each(function() {
                var input = $(this);
                
                if (input.attr('name')) {
                   input.val("")
                }
            })
            $('#sign-submit-button').removeClass('btn-danger')
            $('#sign-submit-button').addClass('btn-success')
            getGuestRegistry();
        },
        error: function (jqXHR, textStatus, errorThrown) {
            $('#sign-submit-button').removeClass('btn-success')
            $('#sign-submit-button').addClass('btn-danger')
        },
    })
}

$(document).ready(getGuestRegistry());

$("#sign-form").submit(function (event) {
    // stop the regular form submission
    event.preventDefault();

    var data = {};
    $("#sign-form :input").each(function() {
        var input = $(this);
        
        if (input.attr('name')) {
            data[input.attr('name')] = input.val();
        }
    })
    addGuest(data);
});