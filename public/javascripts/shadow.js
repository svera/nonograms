Raphael.el.shadow = function (x_offset, y_offset, size, color, radius) {
    if (typeof(this.shadowSet) == 'undefined') {
        this.shadowSet = this.paper.set();
    } else {
        while (this.shadowSet.length > 0) { this.shadowSet.pop().remove(); }
    }
    var width = this.attr('width'),
        height = this.attr('height'),
        left = this.attr('x'),
        top = this.attr('y');

    // Comentado por Sergio
    //radius = radius + 8;
    for (i = size; i > 0; i--) {
        this.shadowSet.push(
            this.paper.rect(left - i + x_offset, top - i + y_offset, width + i*2, height + i*2, radius).attr({fill: color, stroke: 'none', opacity: 0.1 + i*0.02})
        );
    }

    this.onAnimation(function() {
        if (!this.hideShadow)
        {
    	    this.shadow(x_offset, y_offset, size, color, radius);
        }
    });

    this.removeShadow = function() {
        for (var i = 0; i < this.shadowSet.length; i++) {
            if (this.shadowSet[i]) {
                this.shadowSet[i].remove();
            }
        }
        this.hideShadow = true;
    };

    return this.shadowSet.insertBefore(this);
};
