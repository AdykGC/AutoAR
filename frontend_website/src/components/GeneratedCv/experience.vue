<template>
    <section class="experience">
        <h2>EXPERIENCE</h2>

        <div class="job">
            <h3>Job Title</h3>
            <p class="company">Company Name | Date Range</p>
            <ul>
                <li>Key responsibility or achievement</li>
                <li>Another key responsibility</li>
                <li>Significant professional accomplishment</li>
            </ul>
        </div>

        <div class="job">
            <h3>Previous Job Title</h3>
            <p class="company">Previous Company | Date Range</p>
            <ul>
                <li>Key responsibility or achievement</li>
                <li>Another key responsibility</li>
            </ul>
        </div>

    </section>
</template>

<style scoped>

.experience{
    margin-top: 20px;
}

.experience h2{
    border-bottom: 3px solid var(--text-black);
    padding-bottom: 5px;
    color: var(--text-black);
}

.job{
    padding-bottom: 5px;
    margin-bottom: 15px;
}

.job h3 {
    margin: 10px 0 5px 0;
    color: var(--text-black);
}
.job p {
    font-size: 1rem;
    margin: 5px 0 10px 0;
    color: var(--text-black);
}
.job .company {
    color: var(--text3);
    font-style: italic;
}

.job ul {
    font-size: 1rem;
    margin: 5px 0 10px 0;
    color: var(--text-black);
    padding-left: 20px;
}

</style>