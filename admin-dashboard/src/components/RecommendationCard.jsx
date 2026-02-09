/**
 * RecommendationCard Component
 * 
 * Glass-styled card displaying a single recommendation
 * with icon, title, and description.
 */

import React from 'react';

const RecommendationCard = ({ icon, title, description }) => {
    return (
        <div className="recommendation-card">
            <div className="recommendation-card__icon">
                {icon}
            </div>
            <div className="recommendation-card__content">
                <h4>{title}</h4>
                <p>{description}</p>
            </div>
        </div>
    );
};

export default RecommendationCard;
