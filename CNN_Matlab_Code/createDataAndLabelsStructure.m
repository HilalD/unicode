function [st, sl] = createDataAndLabelsStructure()
st.S0   = [7 10 13 14 17 42 50 56 59];
st.S1   = [19 32 37 66];
st.S1_5 = [21 22 44 71];
st.S2   = [2 8 26 29 31 33 39 45 46 47 48 58 60 63 69 70 74];
st.S2_5 = [4 6 16 18 24 27 34 51 62];
st.S3   = [1 5 20 25 38 54 73];
st.S4   = [35];
% labels
sl.S0   = ones(1, length(st.S0))*0;
sl.S1   = ones(1, length(st.S1))*10;
sl.S1_5 = ones(1, length(st.S1_5))*15;
sl.S2   = ones(1, length(st.S2))*20;
sl.S2_5 = ones(1, length(st.S2_5))*25;
sl.S3   = ones(1, length(st.S3))*30;
sl.S4   = ones(1, length(st.S4))*40;