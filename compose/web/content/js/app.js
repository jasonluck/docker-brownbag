

function getGuestRegistry() {
    $.ajax({
        url: "/services/guest",
        type: "GET",
        contentType: 'application/json; charset=utf-8',
        success: function(data) {
            for (var i = 0; i < data.guest.length; i++) {
                var guest = data.guest[i];
                    $("#registry").find('tbody')
                        .append($('<tr>')
                            .append($('<td>')
                                .text(guest.date)
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
        error : function(jqXHR, textStatus, errorThrown) {
        },
    });
}

$(document).ready( getGuestRegistry() );